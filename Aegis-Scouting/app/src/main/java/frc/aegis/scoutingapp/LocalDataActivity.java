package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class LocalDataActivity extends Activity implements View.OnClickListener {

    private TextView localDisplay;
    private ArrayList<TeamEntry> entryList;
    private Button back, clear, upload;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_data);

        localDisplay = findViewById(R.id.local_text);
        back = findViewById(R.id.mainbck_btn);
        clear = findViewById(R.id.clear);
        upload = findViewById(R.id.upload);

        loadData();

        if(entryList.isEmpty()) {
            localDisplay.setText("No Saved Entries");
        }
        else
            localDisplay.setText(entryList.toString());
    }

    public void onClick(View v) {
        if(v.getId() == back.getId()) {
            startActivity(new Intent(this, MainActivity.class));
        }
        else if(v.getId() == clear.getId()) {
            AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
            alertDialog.setTitle("Clear Local Data?");
            alertDialog.setMessage("Once cleared, this data cannot be recovered");
            alertDialog.setNegativeButton("Cancel", ((dialog, which) -> dialog.dismiss()));
            alertDialog.setPositiveButton("Ok", ((dialog, which) -> {
                entryList.clear();
                saveData();
                localDisplay.setText("No Saved Entries");
                Toast.makeText(this, "Local Data Cleared", Toast.LENGTH_SHORT);
            }));
        }
        else if(v.getId() == upload.getId()) {
            for(TeamEntry t : entryList) {
                t.toFile();
            }
            Toast.makeText(this, "Local Data Uploaded", Toast.LENGTH_SHORT);
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
