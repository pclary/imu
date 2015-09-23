#include "lsm303dlhc.h"
#include <i2c_t3.h>
#include "i2c_utils.h"


const uint8_t accel_addr = 0b0011001;
const uint8_t mag_addr = 0b0011110;

const uint8_t CTRL_REG1_A = 0x20;
const uint8_t CTRL_REG2_A = 0x20;
const uint8_t CTRL_REG3_A = 0x22;
const uint8_t CTRL_REG4_A = 0x23;
const uint8_t CTRL_REG5_A = 0x24;
const uint8_t CTRL_REG6_A = 0x25;
const uint8_t REFERENCE_A = 0x26;
const uint8_t STATUS_REG_A = 0x27;
const uint8_t OUT_X_L_A = 0x28;
const uint8_t OUT_X_H_A = 0x29;
const uint8_t OUT_Y_L_A = 0x2a;
const uint8_t OUT_Y_H_A = 0x2b;
const uint8_t OUT_Z_L_A = 0x2c;
const uint8_t OUT_Z_H_A = 0x2d;
const uint8_t FIFO_CTRL_REG_A = 0x2e;
const uint8_t FIFO_SRC_REG_A = 0x2f;
const uint8_t INT1_CFG_A = 0x30;
const uint8_t INT1_SOURCE_A = 0x31;
const uint8_t INT1_THIS_A = 0x32;
const uint8_t INT1_DURATION_A = 0x33;
const uint8_t INT2_CFG_A = 0x34;
const uint8_t INT2_SOURCE_A = 0x35;
const uint8_t INT2_THIS_A = 0x36;
const uint8_t INT2_DURATION_A = 0x37;
const uint8_t CLICK_CFG_A = 0x38;
const uint8_t CLICK_SRC_A = 0x39;
const uint8_t CLICK_THS_A = 0x3a;
const uint8_t TIME_LIMIT_A = 0x3b;
const uint8_t TIME_LATENCY_A = 0x3c;
const uint8_t TIME_WINDOW_A = 0x3d;

const uint8_t CRA_REG_M = 0x00;
const uint8_t CRB_REG_M = 0x01;
const uint8_t MR_REG_M = 0x02;
const uint8_t OUT_X_H_M = 0x03;
const uint8_t OUT_X_L_M = 0x04;
const uint8_t OUT_Z_H_M = 0x05;
const uint8_t OUT_Z_L_M = 0x06;
const uint8_t OUT_Y_H_M = 0x07;
const uint8_t OUT_Y_L_M = 0x08;
const uint8_t SR_REG_M = 0x09;
const uint8_t IRA_REG_M = 0x0a;
const uint8_t IRB_REG_M = 0x0b;
const uint8_t IRC_REG_M = 0x0c;
const uint8_t TEMP_OUT_H_M = 0x31;
const uint8_t TEMP_OUT_L_M = 0x32;


bool accel_init()
{
    set_register(accel_addr, CTRL_REG1_A, 0x97);
    set_register(accel_addr, CTRL_REG4_A, 0x18);
    
    return true;
}


bool mag_init()
{
    set_register(mag_addr, CRA_REG_M, 0x1c);
    set_register(mag_addr, CRB_REG_M, 0xe0);
    set_register(mag_addr, CRB_REG_M, 0x00);
    
    return true;
}


bool accel_data_ready()
{
    return get_register(accel_addr, STATUS_REG_A) & 0b00001000;
}


bool mag_data_ready()
{
    return get_register(mag_addr, SR_REG_M) & 0b00000001;
}


std::array<int16_t, 3> get_accel_data()
{
    uint8_t buffer[6] = {0, 1, 0, 2, 0, 3};
    get_registers(accel_addr, OUT_X_L_A, buffer, 6);
    return {int16_t(uint16_t(buffer[1]) << 8 | buffer[0]),
            int16_t(uint16_t(buffer[3]) << 8 | buffer[2]),
            int16_t(uint16_t(buffer[5]) << 8 | buffer[4])};
}


std::array<int16_t, 3> get_mag_data()
{
    uint8_t buffer[6];
    get_registers(mag_addr, OUT_X_H_M, buffer, 6);
    return {int16_t(uint16_t(buffer[0]) << 8 | buffer[1]),
            int16_t(uint16_t(buffer[2]) << 8 | buffer[3]),
            int16_t(uint16_t(buffer[4]) << 8 | buffer[5])};
}
