#include <SoftwareSerial.h>

#define txPin 2
int sensePin1 = 2;    // the pin the FSR is attached to
int sensePin2 = 3;    // the pin the FSR is attached to

int valueSense1 = 0;
int valueSense2 = 0;

int playerValue1 = 0;
int playerValue2 = 0;

boolean gameEnded = true;
int timeGameStarted = 0;
boolean isDisplayingWinner = false;

SoftwareSerial LCD = SoftwareSerial(0, txPin);
// since the LCD does not send data back to the Arduino, we should only define the txPin
const int LCDdelay=10;  // conservative, 2 actually works

// wbp: goto with row & column
void goTo(int row, int col) {
  LCD.print(0xFE, BYTE);   //command flag
  LCD.print((col + row*64 + 128), BYTE);    //position 
  delay(LCDdelay);
}
void clearLCD(){
  LCD.print(0xFE, BYTE);   //command flag
  LCD.print(0x01, BYTE);   //clear command.
  delay(LCDdelay);
}
void backlightOn() {  //turns on the backlight
  LCD.print(0x7C, BYTE);   //command flag for backlight stuff
  LCD.print(157, BYTE);    //light level.
  delay(LCDdelay);
}
void backlightOff(){  //turns off the backlight
  LCD.print(0x7C, BYTE);   //command flag for backlight stuff
  LCD.print(128, BYTE);     //light level for off.
   delay(LCDdelay);
}
void serCommand(){   //a general function to call the command flag for issuing all other commands   
  LCD.print(0xFE, BYTE);
}

void setup()
{
  pinMode(txPin, OUTPUT);
  //Serial.begin(9600);
  LCD.begin(9600);
  clearLCD();
  goTo(0,1);
  LCD.print("Smashtron 5k6!");
}

void loop()
{
  int newValueSense1 = analogRead(sensePin1); //the voltage on the pin divded by 4 (to scale from 10 bits (0-1024) to 8 (0-255)
  int newValueSense2 = analogRead(sensePin2) ; //the voltage on the pin divded by 4 (to scale from 10 bits (0-1024) to 8 (0-255)
  if ( newValueSense1 > 5 || newValueSense2 > 5 ) { //only update if values pass threshold
    if ( newValueSense1 != valueSense1 || newValueSense2 != valueSense2 ) { // update if values have changed
      if(true==gameEnded) startGame();
      // Store to memory
      valueSense1 = newValueSense1;
      valueSense2 = newValueSense2;
      
      playerValue1 += valueSense1/4;
      playerValue2 += valueSense2/4;
      
      updateScores (playerValue1, playerValue2);
      
      if(playerValue1>=10000||playerValue2>=10000) { 
       int winner = playerValue1 > playerValue2 ? 1 : 2;
       endGame(winner);
      }
    }
  } else {
    
 //Serial.println("Game Ending");
   if(false==gameEnded) {
     if(millis()-timeGameStarted>1000) {
       int winner = playerValue1 > playerValue2 ? 1 : 2;
       endGame(winner);
     }
   }
  }
  delay( 100);
}

void startGame() {
// Serial.println("Game Started");
 
 playerValue1 = 0;
 playerValue2 = 0;

 gameEnded = false;
 timeGameStarted = millis();
}

void endGame(int winner) {
 //Serial.println("Game Ended");
  gameEnded = true;
  clearLCD();
  goTo( 0, 3 );
  LCD.print("player ");
  LCD.print(winner);
  goTo( 1, 1 );
  LCD.print("is the winner!");
  delay(5000);
  setup();
}

void updateScores(int valueSense1, int valueSense2) {
  clearLCD();
    goTo( 0, 0 );
    LCD.print(valueSense1);
    goTo( 1, 0 );
    LCD.print(valueSense2);
    if ( valueSense1 || valueSense2 ) {
      if ( valueSense1 > valueSense2 ) {
        goTo( 0, 6 );
      } else {
        goTo( 1, 6 );
      }
    }
}
