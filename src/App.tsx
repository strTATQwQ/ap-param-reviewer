import React, { useState, useMemo, useRef } from 'react';
import { DiffEditor } from '@monaco-editor/react';
import { 
  Play, Download, ShieldAlert, Upload, Cpu, 
  Eye, EyeOff, CheckCircle2, AlertCircle, ExternalLink, Globe 
} from 'lucide-react';
import { parseParamFile, applyPatches } from './lib/utils';

const decodeZH = (str) => {
  try {
    return JSON.parse(decodeURIComponent(escape(window.atob(str))));
  } catch (e) {
    return {};
  }
};

export default function App() {
  const [fileText, setFileText] = useState("");
  const [goal, setGoal] = useState("Explain: Optimize roll/pitch PIDs for 7-inch drone.");
  const [apiKey, setApiKey] = useState("");
  const [model, setModel] = useState("gemini-2.5-flash");
  const [lang, setLang] = useState("zh");
  
  const [patches, setPatches] = useState([]);
  const [approved, setApproved] = useState(new Set());
  const [loading, setLoading] = useState(false);
  const [hideUnchanged, setHideUnchanged] = useState(true);
  const fileInputRef = useRef(null);

  const t = useMemo(() => {
    const en = { title: "AI Reviewer", input: "1. Param Source", goal: "2. Tuning Goal", audit: "3. Audit Changes", export: "Export", run: "Generate Review", import: "Import", model: "Model", fold: "Fold Clean Rows", show: "Show Full File" };
    if (lang === 'en') return en;
    const zhBase64 = "eyJ0aXRsZSI6IkFJIOiwg+WPguWuoeafpSIsImlucHV0IjoiMS4g5Y+C5pWw5rqQ5paH5Lu2IiwiZ29hbCI6IjIuIOiwg+S8mOebruaghyIsImF1ZGl0IjoiMy4g5Y+Y5pu05a6h5qC4IiwiZXhwb3J0Ijoi5a+85Ye65paH5Lu2IiwicnVuIjoi6I635Y+WIEFJIOW7uuiuriIsImltcG9ydCI6IuWvvOWFpeaWh+S7tiIsIm1vZGVsIjoi5qih5Z6LIiwiZm9sZCI6IuaKmOWPoOacquaUueWKqCIsInNob3ciOiLmmL7npLrlhajmlocifQ==";
    try {
      return { ...en, ...decodeZH(zhBase64) };
    } catch (e) {
      return en;
    }
  }, [lang]);

  const parsed = useMemo(() => {
    try { return parseParamFile(fileText || ""); } catch (e) { return { params: new Map(), lines: [] }; }
  }, [fileText]);

  const preview = useMemo(() => {
    try { return applyPatches(parsed.lines, patches, approved); } catch (e) { return fileText; }
  }, [parsed, patches, approved, fileText]);

  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (f) => setFileText(f.target.result);
      reader.readAsText(file);
    }
  };

  const getWikiUrl = (param) => `https://ardupilot.org/copter/docs/parameters.html#${param}`;

  const runAI = async () => {
    const cleanKey = apiKey.replace(/[^\x20-\x7E]/g, '').trim();
    if (!cleanKey) return alert("Please enter API Key");
    setLoading(true);
    try {
      const contentForAI = (fileText || "").split('\n').slice(0, 2000).join('\n');
      const url = `/google-api/v1beta/models/${model}:generateContent?key=${cleanKey}`;
      
      const systemPrompt = lang === 'zh' 
        ? "You are a senior ArduPilot engineer. Analyze params and provide suggestions. You MUST use Chinese for 'reason' and 'risk' fields. Return JSON: {patches: [{key, op, old, new, reason, risk}]}"
        : "Senior ArduPilot Engineer. Provide suggestions. Use English for reason and risk. Return JSON: {patches: [{key, op, old, new, reason, risk}]}";

      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: `${systemPrompt}\n\nParams:\n${contentForAI}\n\nGoal: ${goal}` }] }],
          generationConfig: { responseMimeType: "application/json", temperature: 0.1 }
        })
      });
      const data = await res.json();
      const rawText = data.candidates[0].content.parts[0].text;
      const parsedJson = JSON.parse(rawText);
      setPatches((parsedJson.patches || []).map((p, i) => ({...p, id: 'p-' + Date.now() + '-' + i})));
      setApproved(new Set());
    } catch (e) { alert("Error: " + e.message); }
    finally { setLoading(false); }
  };

  return (
    <div className="flex flex-col h-screen bg-[#020617] text-slate-300 overflow-hidden font-sans text-sm">
      <header className="h-16 border-b border-slate-800 flex justify-between items-center px-6 bg-[#0f172a]/90 backdrop-blur-md z-30 shadow-2xl">
        <div className="flex items-center gap-3">
          <div className="bg-blue-600 p-1.5 rounded-lg shadow-lg"><Cpu className="text-white" size={20} /></div>
          <h1 className="text-lg font-bold text-white tracking-tight">ArduPilot <span className="text-blue-500 font-black">AI</span> {t.title}</h1>
        </div>
        <div className="flex items-center gap-3">
          <button onClick={() => setLang(lang === 'zh' ? 'en' : 'zh')} className="p-2 hover:bg-slate-800 rounded-lg transition-colors flex items-center gap-2 text-[11px] font-bold text-slate-400 border border-slate-800">
            <Globe size={14}/> {lang.toUpperCase()}
          </button>
          <div className="flex bg-slate-900 border border-slate-800 rounded-lg p-0.5">
            <input type="text" placeholder={t.model} className="bg-transparent px-3 py-1 text-[11px] w-32 outline-none border-r border-slate-800" value={model} onChange={e => setModel(e.target.value)} />
            <input type="password" placeholder="Key" className="bg-transparent px-3 py-1 text-[11px] w-32 focus:w-48 transition-all outline-none" value={apiKey} onChange={e => setApiKey(e.target.value)} />
          </div>
          <button onClick={() => {
            const blob = new Blob([preview], {type: 'text/plain'});
            const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = "tuned.param"; a.click();
          }} className="bg-blue-600 hover:bg-blue-500 px-4 py-1.5 rounded-lg text-xs font-bold shadow-lg flex items-center gap-2 transition-all active:scale-95 text-white">
            <Download size={14}/> {t.export}
          </button>
        </div>
      </header>
      
      <main className="flex-1 flex overflow-hidden">
        <aside className="w-[420px] flex flex-col border-r border-slate-800 bg-[#0f172a] z-20 overflow-hidden shadow-2xl">
          <div className="p-4 space-y-6 overflow-y-auto flex-1 custom-scrollbar">
            <section className="space-y-3">
              <div className="flex justify-between items-center text-[10px] font-black uppercase tracking-widest text-slate-500">
                <span>{t.input}</span>
                <button onClick={() => fileInputRef.current.click()} className="text-blue-500 hover:text-blue-400 flex items-center gap-1 font-bold tracking-normal underline capitalize">{t.import}</button>
                <input type="file" ref={fileInputRef} onChange={handleFileUpload} className="hidden" />
              </div>
              <textarea placeholder="..." className="w-full bg-slate-950/50 rounded-xl p-3 text-[11px] h-32 border border-slate-800 font-mono focus:border-blue-500 outline-none transition-all shadow-inner" value={fileText} onChange={e => setFileText(e.target.value)} />
            </section>

            <section className="space-y-3">
              <label className="text-[10px] font-black uppercase tracking-widest text-slate-500">{t.goal}</label>
              <textarea placeholder="..." className="w-full bg-slate-950/50 rounded-xl p-3 text-[11px] h-20 border border-slate-800 focus:border-blue-500 outline-none transition-all shadow-inner" value={goal} onChange={e => setGoal(e.target.value)} />
              <button onClick={runAI} disabled={loading || !fileText} className="w-full bg-slate-100 hover:bg-white text-slate-950 py-3 rounded-xl font-black text-xs uppercase tracking-wider shadow-xl transition-all flex justify-center items-center gap-2">
                {loading ? <div className="w-4 h-4 border-2 border-slate-300 border-t-slate-900 rounded-full animate-spin"/> : <Play size={14} fill="currentColor"/>}
                {t.run}
              </button>
            </section>

            <section className="space-y-3 pb-8">
              <label className="text-[10px] font-black uppercase tracking-widest text-slate-500">{t.audit} ({patches.length})</label>
              <div className="space-y-3">
                {patches.map(p => {
                  const currentVal = parsed.params.get(p.key)?.value;
                  const mismatch = currentVal && parseFloat(currentVal) !== parseFloat(p.old);
                  return (
                    <div key={p.id} className={`group p-4 rounded-xl border transition-all duration-300 ${mismatch ? 'border-red-900 bg-red-950/20' : 'border-slate-800 bg-slate-900/40 hover:border-slate-600 hover:bg-slate-900/60'}`}>
                      <div className="flex items-center gap-3 mb-3">
                        <input type="checkbox" disabled={mismatch} checked={approved.has(p.id)} onChange={() => {
                          const next = new Set(approved);
                          if (next.has(p.id)) next.delete(p.id); else next.add(p.id);
                          setApproved(next);
                        }} className="w-4 h-4 rounded border-slate-700 bg-slate-800 cursor-pointer" />
                        <span className="font-mono font-bold text-blue-400 text-sm tracking-tight">{p.key}</span>
                        <a href={getWikiUrl(p.key)} target="_blank" rel="noreferrer" className="text-slate-600 hover:text-blue-400 transition-colors"><ExternalLink size={12}/></a>
                        <span className={`ml-auto text-[9px] px-2 py-0.5 rounded-full font-bold uppercase ${p.risk === 'high' ? 'bg-red-500/10 text-red-500' : 'bg-slate-800 text-slate-500'}`}>{p.risk}</span>
                      </div>
                      <div className="flex items-center justify-between text-xs font-mono bg-black/40 p-2 rounded-lg border border-slate-800 mb-2 shadow-inner">
                        <span className="text-slate-600 line-through decoration-red-500/40">{p.old}</span>
                        <span className="text-emerald-500 font-bold px-2 bg-emerald-500/10 rounded">{p.new}</span>
                      </div>
                      <p className="text-[10px] text-slate-400 leading-relaxed pl-3 border-l border-slate-700 font-medium italic">{p.reason}</p>
                      {mismatch && <div className="mt-2 text-[9px] text-red-400 font-bold flex items-center gap-1 bg-red-400/10 p-1.5 rounded border border-red-500/20 uppercase"><AlertCircle size={10}/> Data Conflict: File has {currentVal}</div>}
                    </div>
                  );
                })}
              </div>
            </section>
          </div>
        </aside>

        <section className="flex-1 bg-[#020617] relative flex flex-col shadow-inner">
          <nav className="p-2 border-b border-slate-800 bg-slate-900/20 flex justify-between items-center px-4 backdrop-blur-sm">
            <span className="text-[10px] font-bold text-slate-600 flex items-center gap-2 uppercase tracking-tighter"><CheckCircle2 size={14} className="text-emerald-500/50"/> Param Diff Preview</span>
            <button onClick={() => setHideUnchanged(!hideUnchanged)} className="flex items-center gap-2 text-[10px] font-bold bg-slate-800 hover:bg-slate-700 px-3 py-1 rounded-md text-slate-400 border border-slate-700 transition-all shadow-lg active:translate-y-0.5">
              {hideUnchanged ? t.fold : t.show}
            </button>
          </nav>
          <div className="flex-1">
            <DiffEditor 
              original={fileText || "# Import file to begin review"} 
              modified={preview} 
              language="ini" 
              theme="vs-dark" 
              options={{ 
                readOnly: true, 
                minimap: {enabled: false}, 
                fontSize: 13, 
                renderSideBySide: true,
                hideUnchangedRegions: { enabled: hideUnchanged, revealLineCount: 2, minimumLineCount: 3 },
                lineNumbers: 'on',
                scrollBeyondLastLine: false
              }} 
            />
          </div>
        </section>
      </main>
    </div>
  );
}
