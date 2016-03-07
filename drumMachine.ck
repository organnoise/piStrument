SerialIO serial;
string line;
string stringInts[2];
int data[2];
2 => int digits;

SerialIO.list() @=> string list[];
for( int i; i < list.cap(); i++ )
{
    chout <= i <= ": " <= list[i] <= IO.newline();
}
serial.open(5, SerialIO.B9600, SerialIO.ASCII);

fun void serialPoller(){
    while( true )
    {
        // Grab Serial data
        serial.onLine()=>now;
        serial.getLine()=>line;
        
        if( line$Object == null ) continue;
        if( line == "\n" ) continue;
        
        0 => stringInts.size;
        
        // Line Parser
        
        string pattern;
        "\\[" => pattern;
        for(int i;i<digits;i++){
            "([0-9]+)" +=> pattern;
            if(i<digits-1){
                "," +=> pattern;
            }
        }
        "\\]" +=> pattern;
        if (RegEx.match(pattern, line , stringInts))
        {
            for( 1=>int i; i<stringInts.cap(); i++)  
            {
                // Convert string to Integer
                Std.atoi(stringInts[i])=>data[i-1];
            }
        }
        
        <<< data[0], data[1]>>>;
    }
    
    
}

spork ~ serialPoller();

2 => int NUM_BUTTONS;

int bState[NUM_BUTTONS];
int bLastState[NUM_BUTTONS];




SndBuf hat => dac;
SndBuf kick => dac;
SndBuf snare => dac;

//samples
load("hat",hat);
load("kick",kick);
load("snare",snare);

[kick,snare] @=> SndBuf inst[];


while (true)
{
    buttonUpdate();
    5::ms => now;
}

//Find button serial data and turn it into an OSC message
fun void buttonUpdate(){
    //Iterate through the data from serial
    for(0 => int i; i < NUM_BUTTONS; i++){
        //First piece of data indicates which button it is
        //Second piece of data is that button's value
        if(data[0] == i) data[1] => bState[i];
        
        //If the state is different, send an 
        //OSC message of the newstate
        if(bState[i] != bLastState[i]){
            if(bState[i] == 0){
                Math.random2f(0.8,1.4) => hat.rate; 
                0 => hat.pos;
            }
            else 0 => inst[i].pos;
            }
        
        //Replace the state
        bState[i] => bLastState[i];
    }
    
}

fun void load ( string filename, SndBuf inst )

{
    me.dir() + "/audio/" + filename + ".wav" => inst.read;
    inst.samples() => inst.pos;
}


