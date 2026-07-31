#include "vs_ios_host.h"

static vs_ios_host_callbacks_t callbacks;
static uint8_t joy1;
static uint8_t joy2;
static uint8_t extra;
static uint8_t joy1_press_latch;
static uint8_t extra_press_latch;
static bool exit_requested;
static bool full_frame_requested = true;
static bool running = true;

void vs_ios_host_set_callbacks(const vs_ios_host_callbacks_t *new_callbacks) {
    if (new_callbacks == NULL) {
        callbacks.command = NULL;
        callbacks.present = NULL;
        return;
    }
    callbacks = *new_callbacks;
}

void vs_ios_host_set_input(uint8_t new_joy1, uint8_t new_joy2, uint8_t new_extra, bool new_exit_requested) {
    // Preserve rising edges until the next MicroPython receive() call.  The
    // UIKit input timer is faster than the 30 ms game loop, so a short tap can
    // otherwise be pressed and released between two VM samples.
    joy1_press_latch |= (uint8_t)(new_joy1 & (uint8_t)~joy1);
    extra_press_latch |= (uint8_t)(new_extra & (uint8_t)~extra);
    joy1 = new_joy1 & 0x7f;
    joy2 = new_joy2 & 0x7f;
    extra = new_extra & 0x7f;
    exit_requested = exit_requested || new_exit_requested;
}

void vs_ios_host_request_full_frame(void) {
    full_frame_requested = true;
}

void vs_ios_host_set_running(bool new_running) {
    running = new_running;
}

uint8_t vs_ios_host_get_joy1(void) {
    uint8_t value = joy1 | joy1_press_latch;
    joy1_press_latch = 0;
    return value;
}

uint8_t vs_ios_host_get_joy2(void) {
    return joy2;
}

uint8_t vs_ios_host_get_extra(void) {
    uint8_t value = extra | extra_press_latch;
    extra_press_latch = 0;
    return value;
}

bool vs_ios_host_consume_exit(void) {
    bool result = exit_requested;
    exit_requested = false;
    return result;
}

bool vs_ios_host_consume_full_frame_request(void) {
    bool result = full_frame_requested;
    full_frame_requested = false;
    return result;
}

bool vs_ios_host_is_running(void) {
    return running;
}

void vs_ios_host_post_command(const uint8_t *line, size_t line_length, const uint8_t *data, size_t data_length) {
    if (callbacks.command != NULL) {
        callbacks.command(line, line_length, data, data_length);
    }
}

void vs_ios_host_post_present(const uint8_t *sprites, size_t sprites_length, const uint8_t *frame_meta, size_t frame_meta_length) {
    if (callbacks.present != NULL) {
        callbacks.present(sprites, sprites_length, frame_meta, frame_meta_length);
    }
}
