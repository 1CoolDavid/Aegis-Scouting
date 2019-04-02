package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

import static frc.aegis.scoutingapp.ScoringActivity.initHeaders;
import static frc.aegis.scoutingapp.ScoringActivity.noLocalData;
import static frc.aegis.scoutingapp.ScoringActivity.uploadFile;

public class LocalDataActivity extends Activity implements View.OnClickListener {

    private TextView localDisplay;
    private ArrayList<TeamEntry> entryList, searched;
    private Button back, clear, upload, login, searchLauncher, search;
    private LinearLayout passLayout, bottomLayout, searchLayout;
    private RelativeLayout background;
    private ScrollView dataLayout;
    private EditText localPass, numSearch, roundSearch;
    private TextView dataLabel;
    private boolean searching;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_data);

        localDisplay = findViewById(R.id.local_text);
        back = findViewById(R.id.mainbck_btn);
        clear = findViewById(R.id.clear);
        upload = findViewById(R.id.upload);
        login = findViewById(R.id.local_login);
        searchLauncher = findViewById(R.id.search);
        search = findViewById(R.id.search_entry);
        passLayout = findViewById(R.id.local_pass_layout);
        bottomLayout = findViewById(R.id.entry_bottom_panel);
        dataLayout = findViewById(R.id.data_display_layout);
        searchLayout = findViewById(R.id.search_layout);
        background = findViewById(R.id.background);
        localPass = findViewById(R.id.local_pass);
        numSearch = findViewById(R.id.num_search);
        roundSearch = findViewById(R.id.round_search);
        dataLabel = findViewById(R.id.data_label);

        back.setOnClickListener(this);
        clear.setOnClickListener(this);
        upload.setOnClickListener(this);
        login.setOnClickListener(this);
        search.setOnClickListener(this);
        searchLauncher.setOnClickListener(this);

        bottomLayout.setOnClickListener(this);
        background.setOnClickListener(this);

        loadData();

        if(entryList.isEmpty()) {
            localDisplay.setText("No Saved Entries");
            localDisplay.setTextColor(getResources().getColor(R.color.redPrimary));
            clear.setClickable(false);
            upload.setClickable(false);
            searchLauncher.setClickable(false);
        }
        else {
            localDisplay.setText(entryList.toString());
            localDisplay.setTextColor(getResources().getColor(R.color.greenPrimary));
        }
    }

    public void onClick(View v) {
        if(v.getId() == searchLauncher.getId()) {
            searchLayout.setVisibility(View.VISIBLE);
            dataLayout.setVisibility(View.GONE);
            searching = true;
        }
        else if(v.getId() == search.getId()) {
            if(numSearch.getText().toString().equals("") && roundSearch.getText().toString().equals("")) {
                Toast.makeText(this, "Please fill in at least one of the fields", Toast.LENGTH_SHORT).show();
                return;
            }
            else if(numSearch.getText().toString().equals("")) {
                searched = findRound(Integer.parseInt(roundSearch.getText().toString()));
                changeDisplay(searched);
                dataLabel.setText("Query List");
            }
            else if(roundSearch.getText().toString().equals("")) {
                searched = findTeam(Integer.parseInt(numSearch.getText().toString()));
                changeDisplay(searched);
                dataLabel.setText("Query List");
            }
            else {
                searched = findEntry(Integer.parseInt(numSearch.getText().toString()), Integer.parseInt(roundSearch.getText().toString()));
                changeDisplay(searched);
                dataLabel.setText("Query List");
            }
            searching = false;
            searchLayout.setVisibility(View.GONE);
            dataLayout.setVisibility(View.VISIBLE);
        }
        else if(searching) {
            searching = false;
            searchLayout.setVisibility(View.GONE);
            dataLayout.setVisibility(View.VISIBLE);
        }

        if(v.getId() == back.getId()) {
            startActivity(new Intent(this, MainActivity.class));
        }
        else if(v.getId() == clear.getId()) {
            if(searched != null) {
                AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
                alertDialog.setTitle("Clear Query?");
                alertDialog.setMessage("Once cleared, your query must be re-entered to display");
                alertDialog.setPositiveButton("Ok", ((dialog, which) -> {
                    searched = null;
                    dataLabel.setText("Entry List");
                    localDisplay.setText(entryList.toString());
                    localDisplay.setTextColor(getResources().getColor(R.color.greenPrimary));
                    Toast.makeText(this, "Query Cleared", Toast.LENGTH_SHORT).show();
                }));
                alertDialog.setNegativeButton("Cancel", ((dialog, which) -> {return;}));
                AlertDialog alert = alertDialog.create();
                alert.show();
            }
            else {
                AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
                alertDialog.setTitle("Clear Local Data?");
                alertDialog.setMessage("Once cleared, this data cannot be recovered");
                alertDialog.setNegativeButton("Cancel", ((dialog, which) -> dialog.dismiss()));
                alertDialog.setPositiveButton("Ok", ((dialog, which) -> {
                    entryList.clear();
                    saveData();
                    localDisplay.setText("No Saved Entries");
                    localDisplay.setTextColor(getResources().getColor(R.color.redPrimary));
                    clear.setClickable(false);
                    upload.setClickable(false);
                    searchLauncher.setClickable(false);
                    Toast.makeText(this, "Local Data Cleared", Toast.LENGTH_SHORT).show();
                }));
                AlertDialog alert = alertDialog.create();
                alert.show();
            }
        }
        else if(v.getId() == upload.getId()) {
            if(noLocalData()) {
                initHeaders();
            }
            if(searched != null) {
                for(TeamEntry t : searched) {
                    uploadFile(t);
                }
                Toast.makeText(this, "Query Uploaded", Toast.LENGTH_SHORT).show();
            }
            else {
                for(TeamEntry t : entryList) {
                    uploadFile(t);
                }
                Toast.makeText(this, "Local Data Uploaded", Toast.LENGTH_SHORT).show();
            }
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

    public ArrayList<TeamEntry> findEntry(int num, int round) {
        ArrayList<TeamEntry> entries = new ArrayList<>();
        for(TeamEntry e : entryList) {
            if(e.getRound() == round && e.getTeamNum() == num) {
                entries.add(e);
            }
        }
        return entries;
    }

    public ArrayList<TeamEntry> findTeam(int num) {
        ArrayList<TeamEntry> entries = new ArrayList<>();
        for(TeamEntry e : entryList) {
            if(e.getTeamNum() == num) {
                entries.add(e);
            }
        }
        return entries;
    }

    public ArrayList<TeamEntry> findRound(int round) {
        ArrayList<TeamEntry> entries = new ArrayList<>();
        for(TeamEntry e : entryList) {
            if(e.getRound() == round) {
                entries.add(e);
            }
        }
        return entries;
    }

    public void changeDisplay(ArrayList<TeamEntry> al) {
        if(al == null || al.isEmpty()) {
            localDisplay.setText("No Matching Entries");
            localDisplay.setTextColor(getResources().getColor(R.color.redPrimary));
        }
        else {
            localDisplay.setText(searched.toString());
            localDisplay.setTextColor(getResources().getColor(R.color.greenPrimary));
        }
    }
}