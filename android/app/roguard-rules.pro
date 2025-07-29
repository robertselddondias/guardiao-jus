# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Firebase Auth específico
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# Play Services
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Para evitar problemas com phone auth
-keep class com.google.firebase.auth.PhoneAuthProvider { *; }
-keep class com.google.firebase.auth.PhoneAuthCredential { *; }
