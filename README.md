# qs_audio_player

QS Audio Player

## Getting Started

### Android

Update your main activity

```kotlin
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
}
```

or

```java
public class CustomActivity extends FlutterActivity {
    @Override
    public FlutterEngine provideFlutterEngine(Context context) {
        return AudioServicePlugin.getFlutterEngine(context);
    }
}
```

### iOS

Insert this in your Info.plist file

```xml

<key>UIBackgroundModes</key><array>
<string>audio</string>
</array>
  ```

## Usage

Init player

