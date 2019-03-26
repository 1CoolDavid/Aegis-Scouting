package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

import static frc.aegis.scoutingapp.ScoringActivity.uploadFile;

public class LocalDataActivity extends Activity implements View.OnClickListener {

    private TextView localDisplay;
    private ArrayList<TeamEntry> entryList;
    private Button back, clear, upload, login;
    private LinearLayout passLayout, bottomLayout;
    private ScrollView dataLayout;
    private EditText localPass;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_data);

        localDisplay = findViewById(R.id.local_text);
        back = findViewById(R.id.mainbck_btn);
        clear = findViewById(R.id.clear);
        upload = findViewById(R.id.upload);
        login = findViewById(R.id.local_login);
        passLayout = findViewById(R.id.local_pass_layout);
        bottomLayout = findViewById(R.id.entry_bottom_panel);
        dataLayout = findViewById(R.id.data_display_layout);
        localPass = findViewById(R.id.local_pass);

        back.setOnClickListener(this);
        clear.setOnClickListener(this);
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
            for(TeamEntry t : entryList) {
                uploadFile(t);
            }
            Toast.makeText(this, "Local Data Uploaded", Toast.LENGTH_SHORT);
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
}
