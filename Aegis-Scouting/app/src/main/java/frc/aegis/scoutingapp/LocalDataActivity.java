package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

import static frc.aegis.scoutingapp.ScoringActivity.initHeaders;
import static frc.aegis.scoutingapp.ScoringActivity.noLocalData;
import static frc.aegis.scoutingapp.ScoringActivity.uploadFile;

public class LocalDataActivity extends Activity implements View.OnClickListener {

    private TextView localDisplay;
    private ArrayList<TeamEntry> entryList;
    private Button back, clear, upload, blue, login;
    private LinearLayout passLayout, bottomLayout;
    private ScrollView dataLayout;
    private EditText localPass;
    private static final int DISCOVER_DURATION = 300;
    private static final int REQUEST_BLU = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_data);

        localDisplay = findViewById(R.id.local_text);
        back = findViewById(R.id.mainbck_btn);
        clear = findViewById(R.id.clear);
        upload = findViewById(R.id.upload);
        blue = findViewById(R.id.blueUpload);
        login = findViewById(R.id.local_login);
        passLayout = findViewById(R.id.local_pass_layout);
        bottomLayout = findViewById(R.id.entry_bottom_panel);
        dataLayout = findViewById(R.id.data_display_layout);
        localPass = findViewById(R.id.local_pass);

        back.setOnClickListener(this);
        clear.setOnClickListener(this);
        blue.setOnClickListener(this);
        upload.setOnClickListener(this);
        login.setOnClickListener(this);

        loadData();

        if(entryList.isEmpty()) {
            localDisplay.setText("No Saved Entries");
            localDisplay.setTextColor(getResources().getColor(R.color.redPrimary));
        }
        else {
            localDisplay.setText(entryList.toString());
            localDisplay.setTextColor(getResources().getColor(R.color.greenPrimary));
        }

    }

    public void onClick(View v) {
        if(v.getId() == back.getId()) {
            startActivity(new Intent(this, MainActivity.class));
        }
        else if(v.getId() == clear.getId()) {
            if(entryList.isEmpty()) {
                return;
            }
            AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
            alertDialog.setTitle("Clear Local Data?");
            alertDialog.setMessage("Once cleared, this data cannot be recovered");
            alertDialog.setNegativeButton("Cancel", ((dialog, which) -> dialog.dismiss()));
            alertDialog.setPositiveButton("Ok", ((dialog, which) -> {
                entryList.clear();
                saveData();
                localDisplay.setText("No Saved Entries");
                localDisplay.setTextColor(getResources().getColor(R.color.redPrimary));
                Toast.makeText(this, "Local Data Cleared", Toast.LENGTH_SHORT);
            }));
           AlertDialog alert =  alertDialog.create();
           alert.show();
        }
        else if(v.getId() == upload.getId()) {
            if(entryList.isEmpty()) {
                return;
            }
            if(noLocalData()) {
                initHeaders();
            }
            for(TeamEntry t : entryList) {
                uploadFile(t);
            }
            Toast.makeText(this, "Local Data Uploaded", Toast.LENGTH_SHORT).show();
        }
        else if(v.getId() == login.getId()) {
            if(Integer.parseInt(localPass.getText().toString()) == 127812) {
                passLayout.setVisibility(View.GONE);
                bottomLayout.setVisibility(View.VISIBLE);
                dataLayout.setVisibility(View.VISIBLE);
            }
            else {
                Toast.makeText(this, "Invalid Password", Toast.LENGTH_SHORT).show();
            }
        }
        else if(v.getId() == blue.getId()) {
            sendViaBluetooth();
        }
    }

    public void saveData() {
        SharedPreferences preferences = getSharedPreferences("shared preferences", MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        Gson gson = new Gson();
        String jsonEntries = gson.toJson(entryList);
        editor.putString("KEY", jsonEntries);
        editor.apply();
    }

    public void loadData() {
        SharedPreferences preferences = getSharedPreferences("shared preferences", MODE_PRIVATE);
        Gson gson = new Gson();
        String jsonEntries = preferences.getString("KEY", null);
        Type type = new TypeToken<ArrayList<TeamEntry>>() {}.getType();
        entryList = gson.fromJson(jsonEntries, type);

        if(entryList == null) {
            entryList = new ArrayList<>();
        }
    }

    public void sendViaBluetooth() {
        if (!new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/AnalysisData.csv").exists()) {
            Toast.makeText(this, "No Data to send", Toast.LENGTH_SHORT).show();
            return;
        }

        BluetoothAdapter btAdapter = BluetoothAdapter.getDefaultAdapter();

        if (btAdapter == null) {
            Toast.makeText(this, "Bluetooth is not supported on this device", Toast.LENGTH_LONG).show();
        } else {
            enableBluetooth();
        }
    }

    public void enableBluetooth() {
        Intent discoveryIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
        discoveryIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, DISCOVER_DURATION);
        startActivityForResult(discoveryIntent, REQUEST_BLU);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if (resultCode == DISCOVER_DURATION && requestCode == REQUEST_BLU) {

            Intent intent = new Intent();
            intent.setAction(Intent.ACTION_SEND);
            intent.setType("*/*");

            File f = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).getAbsolutePath() + "/Aegis/AnalysisData.csv");
            intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(f));

            PackageManager pm = getPackageManager();
            List<ResolveInfo> appsList = pm.queryIntentActivities(intent, 0);

            if (appsList.size() > 0) {
                String packageName = null;
                String className = null;
                boolean found = false;

                for (ResolveInfo info : appsList) {
                    packageName = info.activityInfo.packageName;
                    if (packageName.equals("com.android.bluetooth")) {
                        className = info.activityInfo.name;
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    Toast.makeText(this, "Bluetooth havn't been found", Toast.LENGTH_LONG).show();
                } else {
                    intent.setClassName(packageName, className);
                    startActivity(intent);
                }
            }
        } else if (requestCode == 1001 && resultCode == Activity.RESULT_OK) {
            Toast.makeText(this, "Data Sent", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this, "Bluetooth is cancelled", Toast.LENGTH_LONG).show();
        }
    }
}