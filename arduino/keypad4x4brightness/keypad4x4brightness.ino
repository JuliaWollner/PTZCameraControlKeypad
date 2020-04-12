// Einbindung der notwendigen Bibliotheken
#include <Keypad.h>

// Konstante Hilfsvariablen erstellen
const byte ROWS = 4;
const byte COLS = 4;
const byte LEDa = 11;
const byte LEDb = 10;
const byte LEDc = 9;
const byte LEDd = 3;
const int LEDbrigthness = 128;

// Variable Hilfsvariablen erstellen
byte Modenow = 0;
byte Modeold = 0;

// Abbildung Keypad
char hexaKeys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

// Zuweisung Hardwarepins zu Abbildung Keypad
byte rowPins[ROWS] = {8, 7, 6, 5};
byte colPins[COLS] = {A0, A1, A2, A3};

// Initialisierung Keypad
Keypad customKeypad = Keypad(makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS);

void setup()
{
  Serial.begin(9600);
  pinMode(LEDa, OUTPUT);
  pinMode(LEDb, OUTPUT);
  pinMode(LEDc, OUTPUT);
  pinMode(LEDd, OUTPUT);
  changeMode(0);
}

void loop()
{
  char customKey = customKeypad.getKey();
  if (customKey) {
    Serial.println(customKey);
    if (customKey == 'A') {
      changeMode(0);
    }
    else if (customKey == 'B') {
      changeMode(1);
    }
    else if (customKey == 'C') {
      changeMode(2);
    }
    else if (customKey == 'D') {
      if (Modeold == 0) {
        Modeold = Modenow;
      }
      changeMode(3);
    }
    if ((Modenow == 3) && ((customKey == '1') || (customKey == '2') || (customKey == '3') || (customKey == '4') || (customKey == '5') || (customKey == '6') || (customKey == '7') || (customKey == '8'))) {
      changeMode(Modeold);
      delay(250);
      sendoldMode(Modeold);
      Modeold = 0;
    }
  }
}

// Funktion zum Umschalten der Modi
void changeMode(int pin) {
  if (pin == 0) {
    Modenow = 0;
    analogWrite(LEDa, LEDbrigthness);
    analogWrite(LEDb, LOW);
    analogWrite(LEDc, LOW);
    analogWrite(LEDd, LOW);
  }
  else if (pin == 1) {
    Modenow = 1;
    analogWrite(LEDa, LOW);
    analogWrite(LEDb, LEDbrigthness);
    analogWrite(LEDc, LOW);
    analogWrite(LEDd, LOW);
  }
  else if (pin == 2) {
    Modenow = 2;
    analogWrite(LEDa, LOW);
    analogWrite(LEDb, LOW);
    analogWrite(LEDc, LEDbrigthness);
    analogWrite(LEDd, LOW);
  }
  else if (pin == 3) {
    Modenow = 3;
    analogWrite(LEDa, LOW);
    analogWrite(LEDb, LOW);
    analogWrite(LEDc, LOW);
    analogWrite(LEDd, LEDbrigthness);
  }
}

// Funktion zum Senden des vorherigen Modus
void sendoldMode(int Modeold) {
  if (Modeold == 0) {
    Serial.println('A');
  }
  else if (Modeold == 1) {
    Serial.println('B');
  }
  else if (Modeold == 2) {
    Serial.println('C');
  }
  else if (Modeold == 3) {
    Serial.println('D');
  }
}
