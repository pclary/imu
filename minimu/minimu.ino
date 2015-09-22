#include <Arduino.h>
#include <i2c_t3.h>
#include <cstdint>
#include "l3gd20.h"
#include "lsm303dlhc.h"






void setup()
{
    Serial.begin(115200);
    Wire.begin(I2C_MASTER, 0, I2C_PINS_18_19, I2C_PULLUP_EXT, I2C_RATE_100);
    pinMode(13, OUTPUT);
    digitalWrite(13, LOW);
    
    if (!gyro_init())
        digitalWrite(13, HIGH);
    accel_init();
    mag_init();
}


void loop()
{

}


