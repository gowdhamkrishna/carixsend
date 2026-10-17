# Keep WorkManager and Room classes from being obfuscated/stripped by R8
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }
-keep class androidx.sqlite.db.** { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**
