#include <Arduino.h>
#include <SPI.h>
#include "mpu9250.h"
#include <cstdio>
#include <cstddef>


const int ncs_pin = 1;


void setup()
{
    Serial.begin(921600);
    
    delay(1000);

    if (mpu_init(ncs_pin))
        Serial.print("MPU initialized\n");
}


void loop()
{
    sensor_data sensors[512 / 12];
    size_t sample_count = mpu_get_data(ncs_pin, sensors);

    char buf[64];
    for (size_t i = 0; i < sample_count; ++i)
    {
        // int len = snprintf(buf, sizeof buf, "%6d, %6d, %6d, %6d, %6d, %6d\n",
        //                    sensors[i].gyro[0], sensors[i].gyro[1], sensors[i].gyro[2], 
        //                    sensors[i].accel[0], sensors[i].accel[1], sensors[i].accel[2]);
        int len = snprintf(buf, sizeof buf, "%6d, %6d, %6d\n",
                           sensors[i].gyro[0], sensors[i].gyro[1], sensors[i].gyro[2]);
        Serial.write(buf, len);
    }
}
