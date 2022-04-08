package com.strinv.services;

import com.strinv.appLogger;
import org.apache.logging.log4j.Level;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CounterService {

    static int service_calls = 0;
    synchronized public void incrementCalls(){
        service_calls++;
        appLogger.setLog(Level.INFO, "Counter increment");
    }

    @GetMapping("/calls")
    synchronized public int displayCalls(){
        appLogger.setLog(Level.INFO, "Successful calls mapping");
        return service_calls;
    }
}
