package com.strinv.services;

import com.strinv.logger.appLogger;
import com.strinv.stats.Stats;
import org.apache.logging.log4j.Level;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.function.BinaryOperator;
import java.util.stream.Collectors;

@Service
public class StatCollectorService {

    private static List<String> strings = new ArrayList<>();

    private Stats stats;

    @Autowired
    public void setStats(Stats stats) {
        this.stats = stats;
    }

    public Stats getStats() {
        return stats;
    }

    public void increaseTotalRequests() {
        stats.totalRequests++;
    }

    public void increaseWrongRequests() {
        stats.wrongRequests++;
    }

    public void calculate() {

        appLogger.setLog(Level.INFO, "Collecting stats");

        try {
            stats.mostCommon = strings
                    .stream()
                    .reduce(
                            BinaryOperator.maxBy(Comparator.comparing(o -> Collections.frequency(strings, o)))
                    ).orElse("");

            strings = strings
                    .stream()
                    .distinct()
                    .sorted()
                    .collect(Collectors.toList());

            stats.min = strings
                    .stream()
                    .min(Comparator.comparing(String::length))
                    .orElse("");

            stats.max = strings
                    .stream()
                    .max(Comparator.comparing(String::length))
                    .orElse("");

        } catch (NullPointerException exception) {
            appLogger.setLog(Level.ERROR, "Error while collecting stats");
            throw new RuntimeException(exception);
        }
    }

    public void addStrings( String root) {
        strings.add(root);
    }
}
