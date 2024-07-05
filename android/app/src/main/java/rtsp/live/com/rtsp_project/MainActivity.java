package rtsp.live.com.rtsp_project;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.os.Build;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "getSdkInt";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
      super.configureFlutterEngine(flutterEngine);
  
      new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
          (call, result) -> {
            if (call.method.equals("getSdkInt")) {
              result.success(Integer.toString(Build.VERSION.SDK_INT));
            } else {
              result.notImplemented();
            }
          }
        );
    }
}
