package com.example.torniqueteapp

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.material.textfield.TextInputEditText
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException
import com.google.firebase.auth.FirebaseAuthInvalidUserException
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener

class LoginActivity : AppCompatActivity() {
    // Instancias de Firebase
    private lateinit var auth: FirebaseAuth // Para autenticación con email/contraseña
    private lateinit var database: FirebaseDatabase // Para acceder a Realtime Database

    // Componentes de UI
    private lateinit var etEmail: TextInputEditText // Campo para ingresar email
    private lateinit var etPassword: TextInputEditText // Campo para ingresar contraseña
    private lateinit var btnLogin: Button // Botón para iniciar sesión
    private lateinit var progressBar: ProgressBar // Indicador de carga
    private lateinit var tvStatus: TextView // Para mostrar mensajes de estado

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        // Inicialización de Firebase
        auth = FirebaseAuth.getInstance() // Obtiene instancia de Firebase Auth
        database = FirebaseDatabase.getInstance() // Obtiene instancia de Realtime Database

        // Configuración inicial de la actividad
        initViews() // Inicializa los componentes de la vista
        checkCurrentUser() // Verifica si hay usuario logueado
        setupLoginButton() // Configura el botón de login
    }

    /**
     * Inicializa los componentes de la interfaz de usuario
     * vinculándolos con los elementos del layout XML
     */
    private fun initViews() {
        etEmail = findViewById(R.id.etEmail)
        etPassword = findViewById(R.id.etPassword)
        btnLogin = findViewById(R.id.btnLogin)
        progressBar = findViewById(R.id.progressBar)
        tvStatus = findViewById(R.id.tvStatus)
    }

    /**
     * Verifica si hay un usuario actualmente autenticado.
     * Si existe, verifica sus permisos en la tabla de torniquetes
     * y redirige al escáner QR si tiene acceso.
     */
    private fun checkCurrentUser() {
        if (auth.currentUser != null) {
            // Usuario ya logueado, verificar permisos
            checkUserInTourniquetsTable(auth.currentUser?.uid)
        }
    }

    /**
     * Configura el listener del botón de login.
     * Valida los campos de entrada antes de intentar autenticación.
     */
    private fun setupLoginButton() {
        btnLogin.setOnClickListener {
            val email = etEmail.text.toString().trim() // Obtiene y limpia email
            val password = etPassword.text.toString().trim() // Obtiene y limpia contraseña

            if (validateInputs(email, password)) {
                attemptLogin(email, password) // Intenta login si los campos son válidos
            }
        }
    }

    /**
     * Intenta autenticar al usuario con Firebase Auth.
     * @param email Correo electrónico del usuario
     * @param password Contraseña del usuario
     */
    private fun attemptLogin(email: String, password: String) {
        showLoadingState() // Muestra indicador de carga

        auth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    // Login exitoso, obtener UID del usuario
                    val userId = task.result?.user?.uid
                    if (userId != null) {
                        // Verificar permisos en Realtime Database
                        checkUserInTourniquetsTable(userId)
                    } else {
                        showStatusMessage("Error al obtener ID de usuario", R.color.red)
                        hideLoadingState()
                    }
                } else {
                    // Manejar errores de autenticación
                    handleLoginError(task.exception)
                    hideLoadingState()
                }
            }
    }

    /**
     * Verifica si el usuario tiene permisos en la tabla de torniquetes.
     * @param userId ID del usuario a verificar
     */
    private fun checkUserInTourniquetsTable(userId: String?) {
        if (userId == null) {
            showStatusMessage("Usuario no válido", R.color.red)
            auth.signOut() // Cierra sesión si no hay UID válido
            hideLoadingState()
            return
        }

        // Referencia a la tabla de torniquetes en Realtime Database
        val tourniquetsRef = database.getReference("tourniquets")

        // Consulta puntual para verificar si el usuario existe en la tabla
        tourniquetsRef.child(userId).addListenerForSingleValueEvent(object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                if (snapshot.exists()) {
                    // Usuario tiene acceso, proceder
                    handleLoginSuccess()
                } else {
                    // Usuario no tiene permisos
                    showStatusMessage("No tienes acceso al torniquete", R.color.red)
                    auth.signOut() // Cierra la sesión
                }
                hideLoadingState()
            }

            override fun onCancelled(error: DatabaseError) {
                showStatusMessage("Error de base de datos", R.color.red)
                hideLoadingState()
            }
        })
    }

    /**
     * Muestra el estado de carga durante operaciones asíncronas.
     * Deshabilita el botón de login para evitar múltiples intentos.
     */
    private fun showLoadingState() {
        progressBar.visibility = View.VISIBLE
        btnLogin.isEnabled = false
        tvStatus.text = "Verificando acceso..."
        tvStatus.setTextColor(ContextCompat.getColor(this, R.color.blue))
    }

    /**
     * Oculta el estado de carga y reactiva la interfaz.
     */
    private fun hideLoadingState() {
        progressBar.visibility = View.GONE
        btnLogin.isEnabled = true
    }

    /**
     * Maneja el flujo posterior a un login exitoso.
     * Muestra mensaje de éxito y redirige al escáner QR.
     */
    private fun handleLoginSuccess() {
        showStatusMessage("¡Acceso permitido!", R.color.green)
        // Redirige después de 1 segundo para que el usuario vea el mensaje
        Handler(Looper.getMainLooper()).postDelayed({
            navigateToQrScanner()
        }, 1000)
    }

    /**
     * Maneja errores específicos de autenticación.
     * @param exception Excepción generada durante el login
     */
    private fun handleLoginError(exception: Exception?) {
        val errorMessage = when (exception) {
            is FirebaseAuthInvalidUserException -> "Usuario no registrado"
            is FirebaseAuthInvalidCredentialsException -> "Correo o contraseña incorrectos"
            else -> "Error al iniciar sesión. Intente nuevamente"
        }
        showStatusMessage(errorMessage, R.color.red)
    }

    /**
     * Navega a la actividad del escáner QR.
     * Finaliza la actividad actual para que el usuario no pueda volver atrás.
     */
    private fun navigateToQrScanner() {
        startActivity(Intent(this, QrScannerActivity::class.java))
        finish() // Finaliza esta actividad
    }

    /**
     * Muestra un mensaje de estado en la interfaz.
     * @param message Texto del mensaje
     * @param colorRes ID del color para el texto
     */
    private fun showStatusMessage(message: String, colorRes: Int) {
        tvStatus.text = message
        tvStatus.setTextColor(ContextCompat.getColor(this, colorRes))
    }

    /**
     * Valida los campos de entrada antes del login.
     * @param email Correo electrónico a validar
     * @param password Contraseña a validar
     * @return true si los campos son válidos, false si hay errores
     */
    private fun validateInputs(email: String, password: String): Boolean {
        var isValid = true

        if (email.isEmpty()) {
            showInputError(etEmail, "El correo electrónico es requerido")
            isValid = false
        }

        if (password.isEmpty()) {
            showInputError(etPassword, "La contraseña es requerida")
            isValid = false
        }

        return isValid
    }

    /**
     * Muestra un mensaje de error en un campo específico.
     * @param field Campo donde ocurrió el error
     * @param message Mensaje de error a mostrar
     */
    private fun showInputError(field: TextInputEditText, message: String) {
        field.error = message // Muestra error bajo el campo
        showStatusMessage(message, R.color.red) // También en el área de estado
    }
}