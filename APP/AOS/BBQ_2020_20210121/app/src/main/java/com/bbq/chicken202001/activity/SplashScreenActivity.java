package com.bbq.chicken202001.activity;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.animation.AlphaAnimation;
import android.widget.ImageView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.bbq.chicken202001.R;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.target.DrawableImageViewTarget;
import com.bumptech.glide.request.transition.Transition;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;

import java.util.HashMap;


public class SplashScreenActivity extends AppCompatActivity {

    private Context   context;
    private ImageView imgView;
    private ImageView imgBaseView;

    private String marketVersion = "";
    private String deviceVersion = "";
    private String imgUrl = "";

    private final String marketURL  = "https://play.google.com/store/apps/details?id=com.bbq.chicken202001";
    private final String splashKey  = "SplashImage";
    private final String versionKey = "AosVersion";

    private Boolean gifFinish = false;
    private Boolean downloadFinish = false;


    //
    // override
    //


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_screen);

        context     = this;
        imgView     = findViewById(R.id.splash_img);
        imgBaseView = findViewById(R.id.base_img);
        imgView.setScaleType(ImageView.ScaleType.FIT_XY);
        imgBaseView.setScaleType(ImageView.ScaleType.FIT_XY);

        marketVersion = "";
        deviceVersion = "";
        imgUrl = "";


        //
        // 1. glide image load ??? gif 1?????? ??????
        //
        Glide.with(this)
                .load(R.drawable.splash_animation)
                .into(new DrawableImageViewTarget(imgBaseView) {
                    @Override public void onResourceReady(Drawable resource, @Nullable Transition<? super Drawable> transition) {
                        if (resource instanceof GifDrawable) {
                            ((GifDrawable)resource).setLoopCount(1);
                        }
                        super.onResourceReady(resource, transition);
                    }
                });


        //
        // 2. gif ??????????????? ?????? ??????
        //
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                gifFinish = true;
                showDownloadImage();
            }
        }, 1000);


        //
        // 3. Package Version Check
        //
        try {
            PackageInfo pInfo = getPackageManager().getPackageInfo(getPackageName(), PackageManager.GET_META_DATA);
            deviceVersion = pInfo.versionName;         // version name ??? 1.0.4??? version ??? ???????????? String
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }


        //
        // 4. cloud ?????? ??????
        //
        getCloudInfo();
    }


    @Override
    public void finish() {
        super.finish();
        this.overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
    }


    //
    // private ?????? ??????
    //


    /**
     * firebase ?????? ?????? ??????
     */
    private void getCloudInfo() {
        //
        // 1. ?????????????????? ????????? ?????? ??????
        //
        FirebaseRemoteConfig config = FirebaseRemoteConfig.getInstance();
        FirebaseRemoteConfigSettings configSettings = new FirebaseRemoteConfigSettings
                .Builder()
                .setMinimumFetchIntervalInSeconds(0)    // ??????????????? ??????
                .build();

        // setMinimumFetchIntervalInSeconds(60*10*6*24) // ????????? ??????
        // setMinimumFetchIntervalInSeconds(0)          // ??????????????? ??????
        // setMinimumFetchIntervalInSeconds(60 * 10)    // 10 mins

        //
        // 2. ????????? ??? ??????
        //
        HashMap defaultMap = new HashMap <String, String>();
        defaultMap.put(versionKey, "0.0.0");
        config.setDefaultsAsync(defaultMap);
        config.setConfigSettingsAsync(configSettings);


        //
        // 3. ?????? ??? ?????? ?????? ????????? ????????? ?????? ??????
        //
        config.fetchAndActivate().addOnCompleteListener(
                SplashScreenActivity.this, // [????????????]
                task -> {

                    // 3.1 ?????? ?????? ?????? ??????
                    if (task.isSuccessful()) {
                        marketVersion = config.getString(versionKey);
                        imgUrl        = config.getString(splashKey);

                        downloadImage();
                    }
                    // 3.2 ?????? ?????? ?????? ??????
                    else {
                        compareVersion();
                    }
                });
    }


    /**
     * gif animation ????????? download image ????????????.
     */
    private void showDownloadImage() {
        if (downloadFinish && gifFinish) {
            final Handler handler = new Handler();
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    // alpha ??????????????? ??????
                    imgView.setAlpha(1.0f);

                    AlphaAnimation animation = new AlphaAnimation(0.0f, 1.0f);
                    animation.setDuration(1000);
                    animation.setStartOffset(0);
                    animation.setFillAfter(true);
                    imgView.startAnimation(animation);

                    // ?????? ??????
                    final Handler delayHandler = new Handler();
                    delayHandler.postDelayed(() -> compareVersion(), 1000);
                }
            }, 1500);
        }
    }


    /**
     * Glide ???????????? ????????? ???????????? ??????.
     */
    private void downloadImage() {
        Glide.with(context)
                .load(imgUrl)
                .into(new DrawableImageViewTarget(imgView) {
                    @Override public void onResourceReady(Drawable resource, @Nullable Transition<? super Drawable> transition) {
                        downloadFinish = true;
                        imgView.setImageDrawable(resource);
                        showDownloadImage();
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        compareVersion();
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {
                        super.onLoadCleared(placeholder);
                    }
                });
    }


    /**
     * ?????? ??????
     */
    private void compareVersion() {
        //
        // ?????? ???????????? ?????? ??????
        //
        if (marketVersion.equals("")) {
            goMain();
            return;
        }

        //
        // ????????? ?????? ??? ????????? ???????????? ??? ???????????? ??? ?????? ???????????? ?????????
        //
        int market = Integer.parseInt(marketVersion.replace(".", ""));
        int device = Integer.parseInt(deviceVersion.replace(".", ""));
        if (market>device) {
            showAlert();
        } else {
            goMain();
        }
    }


    /**
     * ?????????????????? ????????????.
     */
    private void goMain() {
        Handler delayHandler = new Handler();
        delayHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                startActivity(intent);
                Log.e(this.getClass().getName() , "===========startActivity"  );
                finish();
            }
        }, 1000); // 1??? ????????? ??? ??? ??????
    }


    /**
     * alert ????????????. (play store ??? ??????)
     */
    private void showAlert() {
        AlertDialog.Builder dialog;
        dialog = new AlertDialog.Builder(this);

        dialog.setMessage("????????? ???????????? ??? ??????????????????.")
                .setCancelable(true)
                .setPositiveButton("????????????",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                Intent marketLaunch = new Intent(Intent.ACTION_VIEW);
                                marketLaunch.setData(Uri.parse(marketURL));
                                startActivity(marketLaunch);
                                finish();
                            }
                        })/*.setNegativeButton("??????", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                dialogInterface.dismiss();
//                Handler handler = new Handler();
//                handler.postDelayed(new splashhandler(), 2000);
            }
        })*/;
        AlertDialog alert = dialog.create();
        alert.setTitle("??? ???");
        alert.show();
    }
}
