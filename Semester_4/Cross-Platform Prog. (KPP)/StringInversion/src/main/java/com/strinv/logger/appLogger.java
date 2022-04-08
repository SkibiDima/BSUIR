package com.strinv.logger;

import com.strinv.services.StringInversionService;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;

public class appLogger {
    private static final Logger logger = LogManager.getLogger(StringInversionService.class);

    public static void setLog(Level lvl, String message) {
        logger.log(lvl, message);
    }
}