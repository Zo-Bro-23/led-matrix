#include <SoftwareSerial.h>
SoftwareSerial one (19, 18);

String morseBuffer = "";
bool dotLast = HIGH;
bool dot = HIGH;
bool dashLast = HIGH;
bool dash = HIGH;
bool nextLast = HIGH;
bool next = HIGH;

struct MorseMap {
  const char* code;
  char letter;
};

// Morse code to alphabet mapping (only A-Z for now)
MorseMap morseTable[] = {
  {".-", 'A'},   {"-...", 'B'}, {"-.-.", 'C'}, {"-..", 'D'},  {".", 'E'},
  {"..-.", 'F'}, {"--.", 'G'},  {"....", 'H'}, {"..", 'I'},   {".---", 'J'},
  {"-.-", 'K'},  {".-..", 'L'}, {"--", 'M'},   {"-.", 'N'},   {"---", 'O'},
  {".--.", 'P'}, {"--.-", 'Q'}, {".-.", 'R'},  {"...", 'S'},  {"-", 'T'},
  {"..-", 'U'},  {"...-", 'V'}, {".--", 'W'},  {"-..-", 'X'}, {"-.--", 'Y'},
  {"--..", 'Z'}
};

void setup() {
  for (int i = 2; i <= 10; i++) pinMode(i, OUTPUT);
  //pinMode(0, INPUT_PULLUP);
  //pinMode(1, INPUT_PULLUP);
  pinMode(11, INPUT_PULLUP);
  pinMode(12, INPUT_PULLUP);
  pinMode(13, INPUT_PULLUP);
  Serial.begin(9600);
  one.begin(9600);
}

void displayByte(byte x) {
  digitalWrite(2, LOW);
  delay(100);
  for (int i = 0; i < 8; i++) {
    digitalWrite(i + 3, bitRead(x, i));
  }
  digitalWrite(2, HIGH);
  delay(100);
}

void processLetter(char in) {
  if (in == '.') {
    morseBuffer += '.';
    displayByte(30); // dot
  } else if (in == '-') {
    morseBuffer += '-';
    displayByte(31); // dash
  } else if (in == '/') {
    displayByte(32);
    delay(200);
    char found = '?';
    for (int i = 0; i < sizeof(morseTable) / sizeof(MorseMap); i++) {
      if (morseBuffer == morseTable[i].code) {
        found = morseTable[i].letter;
        break;
      }
    }
    if (found != '?') {
      byte x = found - 63; // A = 65 -> x = 2
      displayByte(x);
      Serial.print("Morse: ");
      Serial.print(morseBuffer);
      Serial.print(" -> ");
      Serial.println(found);
    } else {
      // byte x = 22;
      // displayByte(x);  // U
      // x = 15;
      // displayByte(x);  // N
      // x = 12;
      // displayByte(x);  // K
      // x = 15;
      // displayByte(x);  // N  
      // x = 16;
      // displayByte(x);  // O  
      // x = 24;
      // displayByte(x);  // W  
      // x = 15;
      // displayByte(x);  // N  

      // x = 1;
      // displayByte(x);

      // x = 14;
      // displayByte(x);  // M  
      // x = 16;
      // displayByte(x);  // O 
      // x = 19; 
      // displayByte(x);  // R 
      // x = 20; 
      // displayByte(x);  // S  
      // x = 6;
      // displayByte(x);   // E
      byte x = 28;
      displayByte(28);
      Serial.print("Unknown Morse: ");
      Serial.println(morseBuffer);
    }
    morseBuffer = "";
  }
}

void loop() {
  if (Serial.available()) {
    char in = Serial.read();
    processLetter(in);    
  }

  if (one.available()) {
    String content = one.readStringUntil('/n');
    int length = content.substring(7, 7 + content.substring(7).indexOf(',')).toInt();
    String command = content.substring(9, 9 + length);
    Serial.println(command);
    for (int i = 0; i < command.length(); i++) {
      processLetter(command[i]);
      // delay(350);
    }
  }

  dotLast = dot;
  dashLast = dash;
  nextLast = next;
  dot = digitalRead(11);
  dash = digitalRead(12);
  next = digitalRead(13);

  if (dotLast == HIGH && dot == LOW) {
    processLetter('.');
    Serial.println("DOT");
  }

  if (dashLast == HIGH && dash == LOW) {
    processLetter('-');
    Serial.println("DASH");
  }

  if (nextLast == HIGH && next == LOW) {
    processLetter('/');
    Serial.println("NEXT");
  }
}
