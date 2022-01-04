package com.bbq.chicken202001.activity;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.net.Uri;

//import android.support.v7.app.AlertDialog;
//import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.bbq.chicken202001.R;
import com.bbq.chicken202001.preference.PreferenceManager;
import com.bbq.chicken202001.util.ImageHandler;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;
//import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
//import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings;

import java.util.HashMap;


public class SplashScreenActivity extends AppCompatActivity {

    private Context   context;
    private ImageView imgView;

    String marketVersion, deviceVersion;

    private final String marketURL  = "https://play.google.com/store/apps/details?id=com.bbq.chicken202001";
    private final String splashUrl  = "SplashImage";
    private final String imageName  = "Splash";
    private final String versionKey = "AosVersion";

    String imgUrl;


    //
    // override
    //

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_screen);

        context = this;
        imgView = findViewById(R.id.splash_img);


        //
        // 1. Package Version Check
        //
        try {
            PackageInfo pInfo = getPackageManager().getPackageInfo(getPackageName(), PackageManager.GET_META_DATA);
            deviceVersion = pInfo.versionName;         // versionName은 1.0.4와 version을 표시하는 String
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        //
        // 2. cloud 버전 획득
        //
        getCloudInfo();
    }

    @Override
    public void finish() {
        super.finish();
        this.overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
    }


    //
    // private 함수 정의
    //


    /*-----------------------------------------------------------------------
     * firebase 버전 정보 획득
     *-----------------------------------------------------------------------*/
    private void getCloudInfo() {
        // [파이어베이스에 등록된 key 정의]
        String key   = versionKey;
        String value = "0.0.0";

        //
        // 1. 파이어베이스 리모트 객체 생성
        //
        FirebaseRemoteConfig config = FirebaseRemoteConfig.getInstance();
        FirebaseRemoteConfigSettings configSettings = new FirebaseRemoteConfigSettings
                .Builder()
                .setMinimumFetchIntervalInSeconds(60*10*6*24)
                .build();

        // setMinimumFetchIntervalInSeconds(0)       // 실행시마다 체크
        // setMinimumFetchIntervalInSeconds(60 * 10) // 10 mins

        //
        // 2. 디폴트 값 삽입
        //
        HashMap defaultMap = new HashMap <String, String>();
        defaultMap.put(key, value);
        config.setDefaultsAsync(defaultMap);
        config.setConfigSettingsAsync(configSettings);


        //
        // 3. 최신 앱 버전 확인 이벤트 리스너 수행 실시
        //
        config.fetchAndActivate().addOnCompleteListener(
                SplashScreenActivity.this, // [액티비티]
                new OnCompleteListener<Boolean>() { // [이벤트 리스너]
                    @Override
                    public void onComplete(@NonNull Task<Boolean> task) {

                        // 3.1 해당 키값 확인 성공
                        if (task.isSuccessful()) {
                            marketVersion = config.getString(versionKey);
                            imgUrl        = config.getString(splashUrl);

                            String imgPath = PreferenceManager.getString(context, splashUrl);

                            // 기존에 저장한 bitmap이 있는 경우
                            if (imgUrl.equals(imgPath)) {
                                loadImage();
                                compareVersion();
                            }

                            // 새로운 이미지인 경우
                            else {
                                downloadImage();
                            }
                        }
                        // 3.2 해당 키값 확인 실패
                        else {
//                            marketVersion = "";
                            loadImage();
                            compareVersion();
                        }
                    }
                });

    }


    /*-----------------------------------------------------------------------
     * Glide 이용하여 이미지 다운로드 한다.
     *-----------------------------------------------------------------------*/
    private void downloadImage() {
        Glide.with(context)
                .asBitmap()
                .load(imgUrl)
                .into(new CustomTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                        saveImage(resource);
                        compareVersion();
                    }

                    @Override
                    public void onLoadFailed(@Nullable Drawable errorDrawable) {
                        loadImage();
                        compareVersion();
                    }

                    @Override
                    public void onLoadCleared(@Nullable Drawable placeholder) {

                    }
                });
    }


    /*-----------------------------------------------------------------------
     * sd 카드에 이미지 저장한다.
     *-----------------------------------------------------------------------*/
    private void saveImage(Bitmap bitmap) {
        //
        // 이미지 표시
        //
        imgView.setImageBitmap(bitmap);


        //
        // 이미지 저장
        //
        ImageHandler.save(bitmap, imageName);


        //
        // url 정보 저장
        //
        PreferenceManager.setString(context, splashUrl, imgUrl);
    }


    /*-----------------------------------------------------------------------
     * sd 카드에 있는 이미지 로드한다.
     *-----------------------------------------------------------------------*/
    private void loadImage() {

        //
        // bitmap 이미지 로드
        //
        Bitmap bitmap = ImageHandler.load(imageName);


        //
        // bitmap 존재여부에 따른 처리
        //
        if (bitmap != null) {
            imgView.setImageBitmap(bitmap);
        }
        else {
            // bitmap 없는 경우 preference 초기화, imgView는 drawable 사용 -> 다음에 앱 실행시 이미지 다운로드 하도록 처리
            PreferenceManager.setString(context, splashUrl, "");
            imgView.setBackgroundResource(R.drawable.splash_bbq_new);
        }
    }


    /*-----------------------------------------------------------------------
     * 버전 비교
     *-----------------------------------------------------------------------*/
    private void compareVersion() {
        //
        // 마켓 버전정보 없는 경우
        //
        if (marketVersion.equals("")) {
            goMain();
            return;
        }

        //
        // 마켓정보와 디바이스 정보 비교 처리
        //
        if (marketVersion.equals(deviceVersion)) {
            goMain();
        }
        else {
            showAlert();
        }
    }


    /*-----------------------------------------------------------------------
     * 메인화면으로 이동한다.
     *-----------------------------------------------------------------------*/
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
        }, 1000); // 1초 지연을 준 후 시작
    }


    /*-----------------------------------------------------------------------
     * alert 보여준다. (play store로 이동)
     *-----------------------------------------------------------------------*/
    private void showAlert() {
        AlertDialog.Builder dialog;
        dialog = new AlertDialog.Builder(this);

        dialog.setMessage("버전을 업데이트 후 사용해주세요.")
                .setCancelable(true)
                .setPositiveButton("바로가기",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,
                                                int id) {
                                Intent marketLaunch = new Intent(Intent.ACTION_VIEW);
                                marketLaunch.setData(Uri
                                        .parse(marketURL));
                                startActivity(marketLaunch);
                                finish();
                            }
                        })/*.setNegativeButton("닫기", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                dialogInterface.dismiss();
//                Handler handler = new Handler();
//                handler.postDelayed(new splashhandler(), 2000);
            }
        })*/;
        AlertDialog alert = dialog.create();
        alert.setTitle("안 내");
        alert.show();
    }
}
