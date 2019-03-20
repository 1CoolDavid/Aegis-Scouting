package frc.aegis.scoutingapp;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends Activity implements View.OnClickListener {
    private Button beginbtn, localbtn;
    private EditText numEntry, roundEntry, authorEntry;
    private RadioButton redOpt, blueOpt;
    public static TeamEntry teamEntry;
    public static ArrayList<TeamEntry> entryList = new ArrayList<>();
    boolean color, errors;
    public static SharedPreferences pref;
    public static SharedPreferences.Editor editor;
    public static Gson gson;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        beginbtn = (Button)findViewById(R.id.start_btn);
        localbtn = (Button)findViewById(R.id.local_btn);

        numEntry = (EditText)findViewById(R.id.team_num_entry);
        roundEntry = (EditText)findViewById(R.id.round_entry);
        authorEntry = (EditText)findViewById(R.id.author_entry);

        redOpt = (RadioButton)findViewById(R.id.redTeam);
        blueOpt = (RadioButton)findViewById(R.id.blueTeam);

        beginbtn.setOnClickListener(this);
        localbtn.setOnClickListener(this);
        redOpt.setOnClickListener(this);
        blueOpt.setOnClickListener(this);

        if(teamEntry != null) {
            numEntry.setText(Integer.toString(teamEntry.getTeamNum()));
            authorEntry.setText(teamEntry.getAuthor());
            roundEntry.setText(Integer.toString(teamEntry.getRound()));
            if(teamEntry.getColor())
                blueOpt.toggle();
            else
                redOpt.toggle();
        }
        pref = PreferenceManager.getDefaultSharedPreferences(this.getApplicationContext());
        editor = pref.edit();
        gson = new Gson();
        try {
            entryList.addAll(getData());
        }catch (Exception e) {

        }
    }

    @Override
    public void onClick(View v) {

        if(v.getId() == R.id.start_btn) {
            try {
                teamEntry = new TeamEntry(authorEntry.getText().toString(), Integer.parseInt(numEntry.getText().toString()), Integer.parseInt(roundEntry.getText().toString()), color);
            } catch (Exception e) {
                Toast.makeText(MainActivity.this, "Please fill all fields", Toast.LENGTH_SHORT).show();
                return;
            }
            //Checks for trolls
            errors = !teamEntry.validAuthor() || teamEntry.getAuthor().length() >= 25 || teamEntry.getAuthor().length() <= 0 || teamEntry.getTeamNum() >= 10000 || teamEntry.getTeamNum() <= 0 || teamEntry.getRound() < 0 || (!redOpt.isChecked() && !blueOpt.isChecked());
            if (errors) {
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setTitle("Errors Detected"); //title
                builder.setMessage("Please input a valid team number (positive values, etc). The author name should have no special characters and be no longer than 25 characters. A color must be selected."); //message to display
                builder.setPositiveButton("OK", (dialog, which) -> dialog.dismiss());
                AlertDialog alert = builder.create();
                alert.show();
            } else {
                //Switch activity here
                if(teamEntry.getTeamNum() == 5243) {
                    AlertDialog.Builder is5243 = new AlertDialog.Builder(this);
                    is5243.setTitle("Are You Scouting 5243?");
                    is5243.setMessage("Please confirm that you are scouting 5243 and are not just saying you are from 5243");
                    is5243.setPositiveButton("I'm Scouting 5243", (dialog, which) -> { dialog.dismiss();
                        startActivity(new Intent(MainActivity.this, ScoringActivity.class));
                    });
                    is5243.setNegativeButton("Cancel", (dialog, which) -> {
                        dialog.dismiss();
                        return;
                    });

                    AlertDialog alert = is5243.create();
                    alert.show();
                }
                else {
                    startActivity(new Intent(MainActivity.this, ScoringActivity.class));
                }
            }
        }
        if(v.getId() == R.id.local_btn)

        if(v.getId() == R.id.redTeam)
            color=false;
        if(v.getId() == R.id.blueTeam)
            color=true;
    }

    public static List getData() {
        Type type = new TypeToken<List<TeamEntry>>(){}.getType();
        List<TeamEntry> list = gson.fromJson("KEY", type);
        return list;
    }
}
