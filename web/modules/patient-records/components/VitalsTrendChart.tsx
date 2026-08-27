'use client';

import React from 'react';
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, Legend } from 'recharts';
import { Activity } from 'lucide-react';
import { useVitalsTrends } from '../hooks/useVitalsTrends';

interface VitalsTrendChartProps {
  patientId: string;
}

export function VitalsTrendChart({ patientId }: VitalsTrendChartProps) {
  const trends = useVitalsTrends(patientId);

  if (trends.length === 0) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        No blood pressure or vitals trend logs recorded yet.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Activity className="w-5 h-5 text-[#2E7D32]" />
            Longitudinal Blood Pressure & Pulse Trajectory
          </h3>
          <p className="text-xs text-slate-500">Systolic & Diastolic historical trends (mmHg)</p>
        </div>
      </div>

      <div className="h-64 w-full pt-2">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={trends} margin={{ top: 10, right: 20, left: -10, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
            <XAxis dataKey="date" stroke="#94a3b8" fontSize={11} />
            <YAxis domain={[40, 180]} stroke="#94a3b8" fontSize={11} />
            <Tooltip
              contentStyle={{
                backgroundColor: '#ffffff',
                borderRadius: '12px',
                border: '1px solid #e2e8f0',
                fontSize: '12px',
              }}
            />
            <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />
            <Line
              type="monotone"
              dataKey="systolic"
              name="Systolic BP (mmHg)"
              stroke="#e11d48"
              strokeWidth={2.5}
              dot={{ r: 4, fill: '#e11d48' }}
              activeDot={{ r: 6 }}
            />
            <Line
              type="monotone"
              dataKey="diastolic"
              name="Diastolic BP (mmHg)"
              stroke="#2563eb"
              strokeWidth={2.5}
              dot={{ r: 4, fill: '#2563eb' }}
            />
            <Line
              type="monotone"
              dataKey="pulse"
              name="Heart Rate (bpm)"
              stroke="#388E3C"
              strokeWidth={2}
              strokeDasharray="4 4"
              dot={{ r: 3, fill: '#388E3C' }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
