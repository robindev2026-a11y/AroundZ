# Jetpack Compose specific rules
-keepclassmembers class * {
    @androidx.compose.runtime.Composable *;
}

# Retain line numbers and source files for clean stack traces in crash reporting
-keepattributes SourceFile,LineNumberTable

# Keep attributes needed for reflections, annotations, and generic signatures (e.g. Firebase, Hilt)
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Keep Firebase Firestore and Auth models/DTO packages from renaming/shrinking
-keep class com.coffeecall.app.domain.model.** { *; }
-keep class com.coffeecall.app.data.remote.dto.** { *; }
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
    @com.google.firebase.firestore.PropertyName <methods>;
}

# Keep Hilt / Dagger DI classes and injections
-keep class * { @dagger.hilt.android.lifecycle.HiltViewModel *; }
-keep class * extends androidx.lifecycle.ViewModel
-keep class * extends dagger.hilt.internal.GeneratedComponent
