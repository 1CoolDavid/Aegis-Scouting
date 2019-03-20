package frc.aegis.scoutingapp;

import android.app.Activity;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class LocalDataActivity extends Activity {

    private TextView localDisplay;
    private ArrayList<TeamEntry> entryList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_data);

        localDisplay = findViewById(R.id.local_text);

        loadData();

        localDisplay.setText(entryList.toString());
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
