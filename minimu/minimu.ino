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
    
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    
    delay(1000);

    Serial.print("Initializing...");
    
    if (!gyro_init())
        Serial.write("[init_gyro failed]");
    if (!accel_init())
        Serial.write("[init_accel failed]");
    if (!mag_init())
        Serial.write("[init_mag failed]");

    Serial.print("done!\n");

    
}


void loop()
{

}


