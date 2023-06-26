package com.getui.getuiflut_example;

import android.Manifest;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.getui.getuiflut.GetuiflutPlugin;

import java.util.HashMap;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        String msg = intent.getStringExtra("msg");
        if (msg != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("msg", msg);
            GetuiflutPlugin.transmitUserMessage(map);
        }
        checkUri();
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        String msg = intent.getStringExtra("msg");
        if (msg != null) {
            HashMap<String, Object> map = new HashMap<>();
            map.put("msg", msg);
            GetuiflutPlugin.transmitUserMessage(map);
        }
    }

    private void checkUri() {

        //在Android 开发工具中，参考如下代码生成 Intent
        Intent intent = new Intent(this, MainActivity.class);
        //Scheme协议（gtpushscheme://com.getui.push/detail?）开发者可以自定义
        intent.setData(Uri.parse("gtpushscheme://com.getui.push/detail?"));

        //如果设置了 package，则表示目标应用必须是 package 所对应的应用
        intent.setPackage(getPackageName());
        //intent 中添加自定义键值对，value 为 String 型
        intent.putExtra("String", "payloadStr");
        intent.putExtra("int", 1);
        intent.putExtra("long", 10000L);
        intent.putExtra("Byte", "12");
        intent.putExtra("Boolean", true);
        intent.putExtra("Char", 'A');
        intent.putExtra("Short", Short.parseShort("1"));
        intent.putExtra("Double", 1D);
        intent.putExtra("Float", 1F);
        intent.putExtra("msg", "h呼呼呼呼呼");

        // 应用必须带上该Flag，如果不添加该选项有可能会显示重复的消息，强烈推荐使用Intent.FLAG_ACTIVITY_CLEAR_TOP
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        String intentUri = intent.toUri(Intent.URI_INTENT_SCHEME);

        //得到intent url 值
        //示例：intent://com.getui.push/detail?#Intent;scheme=gtpushscheme;launchFlags=0x4000000;package=com.getui.demo;component=com.getui.demo/com.getui.demo.DemoActivity;S.payload=payloadStr;end

        // 打印出的intentUri值就是设置到推送消息中intent字段的值
        Log.d("intentUri", intentUri);

    }
}
