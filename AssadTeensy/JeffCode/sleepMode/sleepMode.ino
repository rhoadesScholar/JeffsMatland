void setup() {
//  #define TEST_PIN 25
  // put your setup code here, to run once:
  for(int i = 1; i <= 24; i++){
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);
  }
//  pinMode(TEST_PIN, INPUT);
} 

void loop() {
  // put your main code here, to run repeatedly:  
//   for(int i = 1; i <= 24; i++){
//    if(digitalRead(TEST_PIN)){
//      digitalWrite(4, HIGH);
//    }
//    else{
//      digitalWrite(4, LOW);
//    }
//  }
//  delay(1000);
//  for(int i = 1; i <= 24; i++){
//    digitalWrite(4, LOW);
//    delay(1000);
//  }
}
