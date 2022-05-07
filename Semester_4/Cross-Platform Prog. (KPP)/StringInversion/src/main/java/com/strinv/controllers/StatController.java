package com.strinv.controllers;

import com.strinv.services.StatCollectorService;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@AllArgsConstructor
@RestController
public class StatController {
    private final StatCollectorService statCollectorService;

    @GetMapping("/stats")
    public Object getAllStats() {
        statCollectorService.calculate();
        return statCollectorService.getStats();
    }
}
