package com.getui.getuiflut;

import android.app.Activity;
import android.os.Bundle;
import com.igexin.sdk.GTServiceManager;

/**
 * Create by wanghb on 2020-02-24
 * Athor: monkeydbobo
 */
public class GetuiPluginActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GTServiceManager.getInstance().onActivityCreate(this);
    }
}
