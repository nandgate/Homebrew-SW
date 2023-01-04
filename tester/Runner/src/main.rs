extern crate core;

mod tester;

use std::{thread, time};
use crate::tester::Tester;

fn show_ports() {
    let ports = serialport::available_ports().expect("No ports found!");
    for p in ports {
        println!("{}", p.port_name);
    }
}

fn main() {
    show_ports();
    let mut tester = Tester::new("com3");

    for slot in 0..6 {
        tester.select_slot(slot);
        tester.reset_target();
        thread::sleep(time::Duration::from_secs(5));
        if (slot & 1) == 0 {
            tester.show_slot_pass(slot);
        }
        else {
            tester.show_slot_fail(slot);
        }
    }
}
