package com.example.torniqueteapp

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.ServerValue
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class QrScannerActivity : AppCompatActivity() {
    // Instancias de Firebase
    private lateinit var database: FirebaseDatabase // Para acceder a Realtime Database
    private lateinit var auth: FirebaseAuth // Para autenticación

    // Componentes de UI
    private lateinit var previewView: PreviewView // Vista previa de la cámara
    private lateinit var btnLogout: Button // Botón para cerrar sesión
    private lateinit var tvScanResult: TextView // Para mostrar resultados del escaneo

    // Variables para manejo de cámara
    private var cameraProvider: ProcessCameraProvider? = null // Proveedor de cámara
    private lateinit var cameraExecutor: ExecutorService // Ejecutor para procesos de cámara
    private var isAnalyzing = true // Controla si se debe seguir analizando imágenes

    // Lanzador para solicitud de permisos
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        if (isGranted) {
            setupQrScanner() // Configura el escáner si se otorga permiso
        } else {
            showErrorMessage("Se requiere permiso de cámara para escanear QR")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_scanner)

        // Inicialización de Firebase y componentes
        database = FirebaseDatabase.getInstance()
        auth = FirebaseAuth.getInstance()
        cameraExecutor = Executors.newSingleThreadExecutor() // Ejecutor de un solo hilo para cámara

        // Vinculación de vistas
        previewView = findViewById(R.id.previewView)
        btnLogout = findViewById(R.id.btnLogout)
        tvScanResult = findViewById(R.id.tvScanResult)

        // Configuración del botón de logout
        btnLogout.setOnClickListener {
            auth.signOut()
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }

        // Verificación y solicitud de permisos
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            setupQrScanner() // Si ya tiene permisos, configura el escáner
        } else {
            requestPermissionLauncher.launch(android.Manifest.permission.CAMERA)
        }
    }

    /**
     * Configura el escáner QR y la cámara
     */
    @OptIn(ExperimentalGetImage::class)
    private fun setupQrScanner() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
                bindCameraUseCases() // Vincula los casos de uso de la cámara
            } catch (exc: Exception) {
                Log.e(TAG, "Error al inicializar cámara", exc)
                showErrorMessage("Error al iniciar cámara: ${exc.message}")
            }
        }, ContextCompat.getMainExecutor(this))
    }

    /**
     * Vincula los casos de uso de la cámara (previsualización y análisis)
     */
    @androidx.annotation.OptIn(ExperimentalGetImage::class)
    @OptIn(ExperimentalGetImage::class)
    private fun bindCameraUseCases() {
        val cameraProvider = cameraProvider ?: return

        // Configuración de la vista previa
        val preview = Preview.Builder()
            .build()
            .also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

        // Configuración del análisis de imagen para QR
        val imageAnalysis = ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .also {
                it.setAnalyzer(cameraExecutor) { imageProxy ->
                    if (!isAnalyzing) {
                        imageProxy.close()
                        return@setAnalyzer
                    }

                    val image = imageProxy.image ?: return@setAnalyzer
                    val inputImage = InputImage.fromMediaImage(
                        image,
                        imageProxy.imageInfo.rotationDegrees
                    )

                    // Configuración del escáner de códigos QR
                    val options = BarcodeScannerOptions.Builder()
                        .setBarcodeFormats(Barcode.FORMAT_QR_CODE)
                        .build()

                    // Procesamiento del código QR
                    BarcodeScanning.getClient(options)
                        .process(inputImage)
                        .addOnSuccessListener { barcodes ->
                            if (barcodes.isNotEmpty()) {
                                val qrCode = barcodes.first().rawValue
                                qrCode?.let { code ->
                                    isAnalyzing = false // Detiene análisis temporalmente
                                    runOnUiThread {
                                        validateQrCode(code) // Valida el código encontrado
                                    }
                                }
                            }
                        }
                        .addOnCompleteListener {
                            imageProxy.close() // Cierra el proxy de imagen
                        }
                }
            }

        try {
            cameraProvider.unbindAll()
            // Vincula los casos de uso al ciclo de vida
            cameraProvider.bindToLifecycle(
                this,
                CameraSelector.DEFAULT_BACK_CAMERA, // Usa cámara trasera
                preview,
                imageAnalysis
            )
        } catch (exc: Exception) {
            Log.e(TAG, "Error al vincular casos de uso", exc)
            showErrorMessage("Error al iniciar cámara")
        }
    }

    /**
     * Valida el código QR escaneado con Firebase Database
     * @param qrCode El código QR escaneado
     */
    private fun validateQrCode(qrCode: String) {
        Log.d(TAG, "----------------------------------------")
        Log.d(TAG, "QR escaneado (original): $qrCode")

        try {
            // Referencia al código QR en la base de datos
            val qrRef = database.getReference("qr_codes").child(qrCode)
            Log.d(TAG, "Buscando en: /qr_codes/$qrCode")

            qrRef.get().addOnSuccessListener { snapshot ->
                Log.d(TAG, "Respuesta de Firebase: ${snapshot.value}")

                if (snapshot.exists()) {
                    Log.d(TAG, "QR encontrado en Firebase")
                    val status = snapshot.child("status").getValue(String::class.java)
                    Log.d(TAG, "Estado actual: $status")

                    when (status) {
                        "active" -> {
                            Log.d(TAG, "Actualizando estado a 'utilizado'")
                            // Datos para actualizar
                            val updates = hashMapOf<String, Any>(
                                "status" to "used",
                                "usedAt" to ServerValue.TIMESTAMP, // Marca de tiempo del servidor
                                "usedBy" to (auth.currentUser?.uid ?: "unknown") // ID de usuario
                            )

                            qrRef.updateChildren(updates)
                                .addOnSuccessListener {
                                    Log.d(TAG, "QR actualizado correctamente")
                                    showSuccessMessage("Buen viaje") // Mensaje de éxito
                                }
                                .addOnFailureListener { e ->
                                    Log.e(TAG, "Error al actualizar QR", e)
                                    showErrorMessage("Error al actualizar estado del QR")
                                }
                        }
                        "used" -> {
                            Log.d(TAG, "QR ya fue utilizado anteriormente")
                            showErrorMessage("QR utilizado, Genere un nuevo QR para ingresar")
                        }
                        else -> {
                            Log.d(TAG, "QR tiene estado inválido: $status")
                            showErrorMessage("QR no válido")
                        }
                    }
                } else {
                    Log.d(TAG, "QR NO encontrado en Firebase")
                    showErrorMessage("QR no registrado en el sistema")

                    // DEBUG: Muestra todos los códigos QR (solo para desarrollo)
                    database.getReference("qr_codes").get()
                        .addOnSuccessListener { allQRCodes ->
                            Log.d(TAG, "Contenido completo de /qrcodes:")
                            allQRCodes.children.forEach { child ->
                                Log.d(TAG, "Clave: ${child.key} | Valor: ${child.value}")
                            }
                        }
                }
            }.addOnFailureListener { e ->
                Log.e(TAG, "Error al consultar Firebase", e)
                showErrorMessage("Error de conexión con la base de datos")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error al procesar QR", e)
            showErrorMessage("Formato de QR no válido")
        }
    }

    /**
     * Muestra un mensaje de éxito
     * @param message Mensaje a mostrar
     */
    private fun showSuccessMessage(message: String) {
        tvScanResult.text = "✓ $message"
        resetScannerAfterDelay() // Reinicia el escáner después de un retraso
    }

    /**
     * Muestra un mensaje de error
     * @param message Mensaje a mostrar
     */
    private fun showErrorMessage(message: String) {
        tvScanResult.text = "✗ $message"
        resetScannerAfterDelay() // Reinicia el escáner después de un retraso
    }

    /**
     * Reinicia el escáner después de un retraso (3 segundos)
     */
    private fun resetScannerAfterDelay() {
        previewView.postDelayed({
            isAnalyzing = true // Reactiva el análisis
            tvScanResult.text = "Escanea un código QR" // Restablece el mensaje
        }, 3000)
    }

    /**
     * Limpieza al destruir la actividad
     */
    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown() // Apaga el ejecutor
        cameraProvider?.unbindAll() // Libera la cámara
    }

    companion object {
        private const val TAG = "QrScannerActivity" // Tag para logs
    }
}