# This is added as R8 was complaining about 
#ERROR: Missing classes detected while running R8. Please add the missing classes or apply additional keep rules that are generated in /home/wackster/Projects/fyp_calorietrack/build/app/outputs/mapping/release/missing_rules.txt.
#ERROR: R8: Missing class org.tensorflow.lite.gpu.GpuDelegateFactory$Options (referenced from: void org.tensorflow.lite.gpu.GpuDelegate.<init>() and 1 other context)

# Keep TensorFlow Lite GPU Delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options