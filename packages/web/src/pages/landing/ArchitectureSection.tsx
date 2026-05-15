import React from 'react';

const ArchitectureSection: React.FC = () => {
  return (
    <section id="architecture">
      <div className="head">
        <h2 data-i18n="archTitle">让 Agent 有创造力，也有边界。</h2>
        <p data-i18n="archDesc">系统先准备独立 workspace，Agent 只读输入、模板与规则，只写结构化输出。数据库、密钥、对象存储、导出和恢复都由系统掌控。</p>
      </div>
      <div className="arch">
        <div className="agent-map" aria-label="KidMemory architecture illustration">
          <svg className="agent-lines" viewBox="0 0 640 500" preserveAspectRatio="none" aria-hidden="true">
            <path d="M162 132 C238 112 260 192 318 214" />
            <path d="M478 164 C420 178 390 204 330 222" />
            <path d="M176 368 C230 318 276 288 318 246" />
            <path d="M470 356 C424 314 382 282 330 246" />
          </svg>
          <article className="agent-card desktop-node">
            <div className="agent-icon">🖥️</div>
            <b data-i18n="mapDesktopTitle">Desktop Studio</b>
            <span data-i18n="mapDesktopDesc">素材整理、搜图、预览和导出入口。</span>
          </article>
          <article className="agent-card sidecar-node">
            <div className="agent-icon">🧩</div>
            <b data-i18n="mapSidecarTitle">Node Sidecar</b>
            <span data-i18n="mapSidecarDesc">连接配置、workspace、渲染与校验。</span>
          </article>
          <article className="agent-card export-node">
            <div className="agent-icon">💛</div>
            <b data-i18n="mapOutputTitle">Memory Book</b>
            <span data-i18n="mapOutputDesc">结构化书稿、HTML 预览、PDF 和长图。</span>
          </article>
          <article className="agent-card data-node">
            <div className="agent-icon">🗂️</div>
            <b data-i18n="mapDataTitle">Private Library</b>
            <span data-i18n="mapDataDesc">PostgreSQL + pgvector 与本地文件。</span>
          </article>
          <article className="agent-card agent-node">
            <div className="agent-icon">✨</div>
            <b data-i18n="mapAgentTitle">Agent Runner</b>
            <span data-i18n="mapAgentDesc">只读输入和规则，写出可校验结果。</span>
          </article>
          <div className="agent-badge" data-i18n="mapBadge">local-first · safe workspace · publishable output</div>
        </div>
        <div className="principles">
          <article className="mini">
            <h3 data-i18n="p1Title">Workspace first</h3>
            <p data-i18n="p1Desc">每次生成先创建独立 job workspace，包含 input、templates、rules 和 output。</p>
          </article>
          <article className="mini">
            <h3 data-i18n="p2Title">No secret access</h3>
            <p data-i18n="p2Desc">Agent 不直接访问数据库连接、API Key、对象存储凭据或本地敏感配置。</p>
          </article>
          <article className="mini">
            <h3 data-i18n="p3Title">Schema-valid output</h3>
            <p data-i18n="p3Desc">`book.json` 必须可校验，`book.html` 必须可预览，生成结果可追踪。</p>
          </article>
          <article className="mini">
            <h3 data-i18n="p4Title">System-owned export</h3>
            <p data-i18n="p4Desc">PDF、长图、备份恢复和失败重试由系统负责，保证作品稳定可打开。</p>
          </article>
        </div>
      </div>
    </section>
  );
};

export default ArchitectureSection;