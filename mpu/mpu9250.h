#ifndef MPU9250_H
#define MPU9250_H

#include <stdint.h>


#ifdef __cplusplus
extern "C"
{
#endif


typedef struct
{
    int16_t gyro[3];
    int16_t accel[3];
    int16_t mag[3];
} sensor_data;

bool mpu_init(int ncs_pin);
sensor_data mpu_get_data(int ncs_pin);


#ifdef __cplusplus
}
#endif

#endif // MPU9250_H
