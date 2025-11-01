#include <SoftwareSerial.h>
SoftwareSerial one (19, 18);

bool dotLast = HIGH;
bool dot = HIGH;
bool dashLast = HIGH;
bool dash = HIGH;
bool nextLast = HIGH;
bool next = HIGH;
bool send = HIGH;
bool sendLast = HIGH;

String command = "";

void setup() {
  // put your setup code here, to run once:
  pinMode(0, INPUT_PULLUP);
  pinMode(1, INPUT_PULLUP);
  pinMode(11, INPUT_PULLUP);
  pinMode(12, INPUT_PULLUP);
  pinMode(13, INPUT_PULLUP);
  Serial.begin(9600);
  one.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  dotLast = dot;
  dashLast = dash;
  nextLast = next;
  sendLast = send;
  dot = digitalRead(11);
  dash = digitalRead(12);
  next = digitalRead(13);
  send = digitalRead(0);

  if (dotLast == HIGH && dot == LOW) {
    command += ".";
    Serial.println("DOT");
  }

  if (dashLast == HIGH && dash == LOW) {
    command += "-";
    Serial.println("DASH");
  }

  if (nextLast == HIGH && next == LOW) {
    command += "/";
    Serial.println("NEXT");
    //one.print("AT+SEND=0,1,-\r\n");
  }

  if (sendLast == HIGH && send == LOW) {
    one.print("AT+SEND=0," + String(command.length()) + "," + command + "\r\n");
    Serial.println("AT+SEND=0," + String(command.length()) + "," + command + "\r\n");
    Serial.println("SEND");
    command = "";
  }

  // if (Serial.available()) {
  //  one.write(Serial.read());
  // }

  if (one.available()) {
    Serial.write(one.read());
  }
}
