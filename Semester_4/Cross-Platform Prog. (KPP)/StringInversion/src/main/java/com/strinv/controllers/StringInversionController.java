package com.strinv.controllers;

import com.strinv.logger.appLogger;
import com.strinv.domain.StringInversion;
import com.strinv.services.StringInversionService;
import lombok.AllArgsConstructor;
import org.apache.logging.log4j.Level;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@AllArgsConstructor
@RestController
public class StringInversionController {

    private final StringInversionService service;
    CounterController calls = new CounterController();

    @GetMapping("/inversion")
    public StringInversion getController(@RequestParam(value = "ent_string") String ent_string){

        calls.incrementCalls();

        StringInversion result = service.inversion(ent_string);
        //StringInversion result = new StringInversionService().inversion(ent_string);
        appLogger.setLog(Level.INFO, "Successful mapping");
        return result;
    }
}
