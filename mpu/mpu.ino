#include <Arduino.h>
#include <SPI.h>
#include "mpu9250.h"


const int ncs_pin = 1;


void setup()
{
    Serial.begin(230400);
    
    delay(1000);

    mpu_init(ncs_pin);
}


void loop()
{
}
