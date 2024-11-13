package io.flutter.app;  // Ensure this matches your app's package

import android.content.Context;
import androidx.annotation.CallSuper;
import androidx.multidex.MultiDexApplication;

/**
 * Extension of {@link android.app.Application}, adding multidex support.
 */
public class MainApplication extends MultiDexApplication {
  @Override
  @CallSuper
  protected void attachBaseContext(Context base) {
    super.attachBaseContext(base);
    // MultiDex.install(this);  // Usually, this is no longer necessary when using MultiDexApplication
  }

  @Override
  public void onCreate() {
    super.onCreate();
    // Any other app initialization logic here
  }
}
