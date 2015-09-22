#include "l3gd20.h"
#include <i2c_t3.h>
#include "i2c_utils.h"
#include <cstdint>


const uint8_t gyro_addr = 0b1101011;

const uint8_t WHO_AM_I = 0x0f;
const uint8_t CTRL_REG1 = 0x20;
const uint8_t CTRL_REG2 = 0x21;
const uint8_t CTRL_REG3 = 0x22;
const uint8_t CTRL_REG4 = 0x23;
const uint8_t CTRL_REG5 = 0x24;
const uint8_t REFERENCE = 0x25;
const uint8_t OUT_TEMP = 0x26;
const uint8_t STATUS_REG = 0x27;
const uint8_t OUT_X_L = 0x28;
const uint8_t OUT_X_H = 0x29;
const uint8_t OUT_Y_L = 0x2a;
const uint8_t OUT_Y_H = 0x2b;
const uint8_t OUT_Z_L = 0x2c;
const uint8_t OUT_Z_H = 0x2d;
const uint8_t FIFO_CTRL_REG = 0x2e;
const uint8_t FIFO_SRC_REG = 0x2f;
const uint8_t INT1_CFG = 0x30;
const uint8_t INT1_SRC = 0x31;
const uint8_t INT1_TSH_XH = 0x32;
const uint8_t INT1_TSH_XL = 0x33;
const uint8_t INT1_TSH_YH = 0x34;
const uint8_t INT1_TSH_YL = 0x35;
const uint8_t INT1_TSH_ZH = 0x36;
const uint8_t INT1_TSH_ZL = 0x37;
const uint8_t DURATION = 0x38;


bool gyro_init()
{
    if (get_register(gyro_addr, WHO_AM_I) != 11010100)
        return false;

    return true;
}
