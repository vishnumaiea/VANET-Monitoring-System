
//////////////////////////////////////////////////////////////////////////

//  VANET SYSTEM MONITOR
//  Copyright (c) 2015 Vishnu M Aiea
//  E-mail : vishnumaiea@gmail.com
//  Web : www.vishnumaiea.in
//  Date created : 10:07 PM 18-03-2015, Wednesday
//  Last modified : 10:07 PM 18-03-2015, Wednesday
  
///////////////////////////////////////////////////////////////////////////


#include <SoftwareSerial.h>

#define vref 5.09

SoftwareSerial gpsSerial(13, 12); //Rx and Tx

int byte_buffer; // receive serial data byte
unsigned int finish = 0;  // indicates end of message
unsigned int pos_cnt = 0;  // position counter
unsigned int lat_cnt = 0;  // latitude data counter
unsigned int log_cnt = 0;  // longitude data counter
unsigned int spd_cnt = 0;  //speed data counter
unsigned int flag = 0;  // GPS flag
unsigned int com_cnt = 0;  // comma counter

char latitude[20];   // latitude array
char longitude[20];  // longitude array
char GPS_speed[10];  // GPS speed array
char lat_dir; // latitude direction
char long_dir; // longitude direction

//-------------------------------------------------------------------------
const int pinX = A0; //adc pins for ax meter
const int pinY = A1;
const int pinZ = A2;

int valueX; //ADC readings
int valueY;
int valueZ;

float sensitivityX = 0.400; //ax sensitivity
float sensitivityY = 0.370;
float sensitivityZ = 0.330;

float voltX, voltY, voltZ; //voltage readings
float deltaVoltX, deltaVoltY, deltaVoltZ; //change in voltage
float axX, axY, axZ; //ax in g

//--------------------------------------------------------------------------

void setup() {
  Serial.begin(9600);
  gpsSerial.begin(9600);
}

void loop() {
  valueX = analogRead(pinX);
  valueY = analogRead(pinY);
  valueZ = analogRead(pinZ);

  voltX = valueX * vref / 1024;
  voltY = valueY * vref / 1024;
  voltZ = valueZ * vref / 1024;

  deltaVoltX = voltX - 1.525;
  deltaVoltY = voltY - 1.525;
  deltaVoltZ = voltZ - 1.525;

  axX = deltaVoltX / sensitivityX;
  axY = deltaVoltY / sensitivityY;
  axZ = deltaVoltZ / sensitivityZ;
  
  receiveGPRMC();
  finish = 0;
  pos_cnt = 0;
  
  Serial.write("longitude,");
  Serial.write(longitude);
  //printDouble(longitude, 5);
  Serial.write(",");
  delay(10);

  Serial.write("latitude,");
  Serial.write(latitude);
  //printDouble(latitude, 5);
  Serial.write(",");
  delay(10);
  
  Serial.write("longDirection,");
  Serial.write(long_dir);
  Serial.write(",");
  delay(10);
  
  Serial.write("latDirection,");
  Serial.write(lat_dir);
  Serial.write(",");
  delay(10);
  
  //Serial.write("status,");
  //Serial.write("Moving,");
  //delay(10);
  
  Serial.write("speed,");
  Serial.write(GPS_speed);
  //printDouble(GPS_speed, 5);
  Serial.write(",");
  delay(50);
  
  //Serial.write("direction,");
  //Serial.write("North-East,");
  //delay(100);

  //Serial.write("distance,");
  //Serial.write("132,");
  //delay(100);

  Serial.write("accelx,");
  //Serial.print(axX);
  printDouble(axX, 5);
  Serial.write(",");
  delay(10);

  Serial.write("accely,");
  //Serial.print(axX);
  printDouble(axY, 5);
  Serial.write(",");
  delay(10);

  Serial.write("accelz,");
  //Serial.print(axX);
  printDouble(axZ, 5);
  Serial.write(",");
  delay(10);

}
///////////////////////////////////////////////////////////////////////////

void printDouble( double val, byte precision) {
  // prints val with number of decimal places determine by precision
  // precision is a number from 0 to 6 indicating the desired decimial places
  // example: printDouble( 3.1415, 2); // prints 3.14 (two decimal places)

  Serial.print (int(val));  //prints the int part
  if ( precision > 0) {
    Serial.print("."); // print the decimal point
    unsigned long frac;
    unsigned long mult = 1;
    byte padding = precision - 1;
    while (precision--)
      mult *= 10;

    if (val >= 0)
      frac = (val - int(val)) * mult;
    else
      frac = (int(val) - val ) * mult;
    unsigned long frac1 = frac;
    while ( frac1 /= 10 )
      padding--;
    while (  padding--)
      Serial.print("0");
    Serial.print(frac, DEC) ;
  }
}
///////////////////////////////////////////////////////////////////////////

void receiveGPRMC() {
  while (finish == 0) {
    while (gpsSerial.available() > 0) { // Check GPS data
      byte_buffer = gpsSerial.read();
      flag = 1;

      if ( byte_buffer == '$' && pos_cnt == 0)  // finding GPRMC header
        pos_cnt = 1;

      if ( byte_buffer == 'G' && pos_cnt == 1)
        pos_cnt = 2;

      if ( byte_buffer == 'P' && pos_cnt == 2)
        pos_cnt = 3;

      if ( byte_buffer == 'R' && pos_cnt == 3)
        pos_cnt = 4;

      if ( byte_buffer == 'M' && pos_cnt == 4)
        pos_cnt = 5;

      if ( byte_buffer == 'C' && pos_cnt == 5)
        pos_cnt = 6;

      if ( pos_cnt == 6 && byte_buffer == ',') { // count commas in message
        com_cnt++;
        flag = 0;
      }

      if (com_cnt == 3 && flag == 1) {
        latitude[lat_cnt++] =  byte_buffer; // Latitude
        flag = 0;
      }

      if (com_cnt == 4 && flag == 1) {
        lat_dir =  byte_buffer; // Latitude Direction N/S
        flag = 0;
      }

      if (com_cnt == 5 && flag == 1) {
        longitude[log_cnt++] =  byte_buffer; // Longitude
        flag = 0;
      }

      if (com_cnt == 6 && flag == 1) {
        long_dir =  byte_buffer; // Longitude Direction E/W
        flag = 0;
      }

      if (com_cnt == 7 && flag == 1) {
        GPS_speed[spd_cnt++] =  byte_buffer; // Speed in knot
        flag = 0;
      }

      if ( byte_buffer == '*' && com_cnt >= 7) { // end of GPRMC message
        com_cnt = 0;
        lat_cnt = 0;
        log_cnt = 0;
        spd_cnt = 0;
        flag     = 0;
        finish  = 1;

      }
    }
  }
}
///////////////////////////////////////////////////////////////////////////


