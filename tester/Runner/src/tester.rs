use core::time::Duration;
use std::io::{Read, Write};
use serialport::COMPort;
use csv::ReaderBuilder;

const _CMD_QUERY_INFO: char = '?';
const _CMD_SELECT_SLOT: [char; 6] = ['1', '2', '3', '4', '5', '6'];
const _CMD_SELECT_NO_SLOT: char = '0';
const _CMD_RED: [char; 6] = ['z', 'x', 'c', 'v', 'b', 'n'];
const _CMD_GREEN: [char; 6] = ['a', 's', 'd', 'f', 'g', 'h'];
const _CMD_YELLOW: [char; 6] = ['q', 'w', 'e', 'r', 't', 'y'];
const _CMD_OFF: [char; 6] = ['Q', 'W', 'E', 'R', 'T', 'Y'];
const _CMD_ALL_RED: char = 'm';
const _CMD_ALL_GREEN: char = 'j';
const _CMD_ALL_YELLOW: char = 'u';
const _CMD_ALL_OFF: char = 'U';
const _CMD_RESET_ACTIVE: char = 'i';
const _CMD_IRQ0_ACTIVE: char = 'o';
const _CMD_IRQ1_ACTIVE: char = 'p';
const _CMD_RESET_INACTIVE: char = 'I';
const _CMD_IRQ0_INACTIVE: char = 'O';
const _CMD_IRQ1_INACTIVE: char = 'P';
const _CMD_RESET_PULSE: char = '!';
const _CMD_IRQ0_PULSE: char = '@';
const _CMD_IRQ1_PULSE: char = '#';
const _CMD_ALL_ACTIVE: char = '&';
const _CMD_ALL_INACTIVE: char = '*';


pub struct Tester {
    port: COMPort,
    slots: usize
}

pub struct TesterInfo {
    pub version: String,
    pub slots: usize
}

impl Default for TesterInfo {
    fn default() -> Self {
        TesterInfo {
            version: "unkown".to_string(),
            slots: 0
        }
    }
}

impl Tester {
    pub fn new(port_name: &str) -> Tester {
        let mut t = Tester {
            port: serialport::new(port_name, 9600)
                .timeout(Duration::from_millis(100))
                .open_native().expect("Failed to open port"),
            slots: 0
        };

        let mut info: TesterInfo = TesterInfo::default();
        Tester::get_info(&mut t, &mut info);
        t.slots = info.slots;

        Tester::send_cmd(&mut t, _CMD_ALL_INACTIVE);
        Tester::send_cmd(&mut t, _CMD_SELECT_NO_SLOT);
        Tester::send_cmd(&mut t, _CMD_ALL_OFF);
        return t;
    }

    pub fn get_info(&mut self, info:&mut TesterInfo)  {
        self.send_cmd(_CMD_QUERY_INFO);

        let mut reader = ReaderBuilder::new()
            .has_headers(false)
            .from_reader(&mut self.port);

        if let Some(csv) = reader.records().next() {
            let records = csv.expect("csv malformed");
            let name = records.get(0).expect("name missing in info message");
            let version = records.get(1).expect("version missing in info message");
            let slots = records.get(2).expect("slots missing in info message");
            //println!("name: {}  version: {}  slots: {}", name, version, slots);
            if name.eq("tester") {
                info.version = version.to_string();
                info.slots = slots.parse().unwrap();
            }
        }
    }

    pub fn select_slot(&mut self, slot: usize) {
        if slot <= self.slots {
            // Select the slot
            self.send_cmd(_CMD_SELECT_SLOT[slot]);

            // make the select slot yellow
            self.send_cmd(_CMD_YELLOW[slot]);
        }
        else {
            panic!("invalid slot: {}", slot);
        }
    }

    pub fn show_slot_pass(&mut self, slot: usize) {
        if slot <= self.slots {
            self.send_cmd(_CMD_GREEN[slot]);
        }
        else {
            panic!("invalid slot: {}", slot);
        }
    }

    pub fn show_slot_fail(&mut self, slot: usize) {
        if slot <= self.slots {
            self.send_cmd(_CMD_RED[slot]);
        }
        else {
            panic!("invalid slot: {}", slot);
        }
    }

    pub fn reset_target(&mut self) {
        self.send_cmd(_CMD_RESET_PULSE);
    }


    fn send_cmd(&mut self, cmd: char) {
        const PROMPT: u8 = 62;

        // wait for prompt
        let mut c:[u8; 1] = [0];
        loop {
            // Read one character at a time looking for the prompt
            if let Ok(_) =  self.port.read_exact(&mut c) {
                if c[0] == PROMPT {
                    break;
                }
            }
            else {
                println!("Sync to prompt...");
                self.port.write("\n".as_bytes()).expect("Write failed!");
                self.port.flush().expect("Flush failed!");
            }
        }

        let buffer: [u8; 1] = [cmd as u8];
        self.port.write(&buffer).expect("Write failed!");
        self.port.flush().expect("Flush failed!");
        //println!("Sent command: {}", cmd);
    }
}