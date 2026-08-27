'use client';

import { useMemo } from 'react';

export interface MedicationCalculation {
  totalDoseMg: number;
  totalQuantityPills: number;
  dailyFrequencyCount: number;
}

export function useMedicationCalculator(dose: string, frequency: string, duration: string): MedicationCalculation {
  return useMemo(() => {
    // Parse numeric dose
    const doseMatch = dose.match(/(\d+(\.\d+)?)/);
    const doseNum = doseMatch ? parseFloat(doseMatch[0]) : 0;

    // Parse frequency
    let dailyCount = 1;
    const lowerFreq = frequency.toLowerCase();
    if (lowerFreq.includes('bid') || lowerFreq.includes('twice') || lowerFreq.includes('bd')) {
      dailyCount = 2;
    } else if (lowerFreq.includes('tid') || lowerFreq.includes('thrice') || lowerFreq.includes('tds')) {
      dailyCount = 3;
    } else if (lowerFreq.includes('qid') || lowerFreq.includes('four times')) {
      dailyCount = 4;
    } else if (lowerFreq.includes('prn') || lowerFreq.includes('needed')) {
      dailyCount = 1;
    }

    // Parse duration in days
    let days = 7;
    const daysMatch = duration.match(/(\d+)/);
    if (daysMatch) {
      const num = parseInt(daysMatch[0], 10);
      if (duration.toLowerCase().includes('month')) {
        days = num * 30;
      } else if (duration.toLowerCase().includes('week')) {
        days = num * 7;
      } else {
        days = num;
      }
    }

    const totalQuantityPills = dailyCount * days;
    const totalDoseMg = totalQuantityPills * doseNum;

    return {
      totalDoseMg,
      totalQuantityPills,
      dailyFrequencyCount: dailyCount,
    };
  }, [dose, frequency, duration]);
}
