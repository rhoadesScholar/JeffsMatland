// Pin 13 has the LED on Teensy 3.1 - will use this pin also as the square wave TTL output
int ledpin = 8;
int raw = 0;
int thresh = 15;
int base = 400;
int oldBase = 400;
int i = 0;
char in;
int d = 0;
int bias = 99;

// the setup routine runs once when you press reset:
FASTRUN void setup() {
  //analogWriteResolution(12);
  //pinMode(A14,OUTPUT);
  //analogRead(A4);
  pinMode(ledpin, OUTPUT);
  
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(20, OUTPUT);
  pinMode(21, OUTPUT);
  pinMode(22, OUTPUT);
  pinMode(23, OUTPUT);
  
  digitalWrite(6, LOW);
  digitalWrite(7, LOW);
  digitalWrite(9, LOW);
  digitalWrite(10, LOW);
  digitalWrite(11, LOW);
  digitalWrite(5, LOW);
  digitalWrite(4, LOW);
  digitalWrite(20, LOW);
  digitalWrite(21, LOW);
  digitalWrite(22, LOW);
  digitalWrite(23, LOW);
  Serial.begin(9600);
}

FASTRUN void loop() {
  
  raw = analogRead(A4);
  d = raw - oldBase;
  if (d > thresh) {
    digitalWrite(ledpin, HIGH);
//    Serial.println(d);
  }
  else{
    digitalWrite(ledpin, LOW);
  }
  while(Serial.available()){
    in = Serial.read();
    if (in == ','){
      thresh = thresh - 10;
    }
    if(in == '.'){
      thresh = thresh + 10;
    }
    if (in == 'l'){
      thresh--;
    }
    if(in == ';'){
      thresh++;
    }
    if(in == 'j'){
      bias--;
    }
    if(in == 'k'){
      bias++;
    }
    Serial.print("thresh is ");
    Serial.println(thresh);
  }  
  if (i == 1000){
    oldBase = (bias/100)*oldBase + (1-(bias/100))*base;
    i = 0;
  }
  base = (bias/100)*base + (1-(bias/100))*raw;
  i++;
  Serial.print(-8);  // To freeze the lower limit
  Serial.print(" ");
  Serial.print(8);  // To freeze the upper limit
  Serial.print(" ");
  Serial.print(-thresh);  // To freeze the lower limit
  Serial.print(" ");
  Serial.print(thresh);  // To freeze the upper limit
  Serial.print(" ");
  Serial.print(d);
  Serial.print(" ");
  Serial.println(raw-base);
//  
  delayMicroseconds(1); // to slow it down a bit if required
}
