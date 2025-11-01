void setup() {
  // put your setup code here, to run once:
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  byte x;
  if(Serial.available()){
    char in = Serial.read();
    if (in >= 65 && in <= 90) x = (in - 63);
    else if (in == '.') x = 28;
    else if (in == '/') x = 1;
    else if (in == '?') x = 29;
    else if (in == '0') x = 30;
    else if (in == '1') x = 31;
    else if (in == '>') x = 32;
    else return;
    digitalWrite(2, LOW);
    delay(100);
    for(int i=0; i<8; i++){
      digitalWrite(i + 3, bitRead(x, i));
      Serial.println(x);
    }
    digitalWrite(2, HIGH);
    delay(100);
  }
}
