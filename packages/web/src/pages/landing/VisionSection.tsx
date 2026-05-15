import React from 'react';

const VisionSection: React.FC = () => {
  return (
    <section id="vision">
      <div className="head">
        <h2 data-i18n="visionTitle">不是保存图片，而是重建家庭记忆的结构。</h2>
        <p data-i18n="visionDesc">KidMemory 的最终态是一套家庭记忆工作台：桌面端长期管理素材，Web Companion 负责手机扫码采集与轻量浏览，语义搜索重新发现，Agent 生成书稿，系统负责校验、预览、导出和归档。</p>
      </div>
      <div className="cards">
        <article className="card">
          <h3 data-i18n="v1Title">Curated, not piled up</h3>
          <p data-i18n="v1Desc">孩子的画作、照片、手工和早期表达不应该只堆在相册里。它们需要被重新挑选、排序、连接成故事。</p>
        </article>
        <article className="card">
          <h3 data-i18n="v2Title">AI as an editor</h3>
          <p data-i18n="v2Desc">Agent 像编辑助理一样整理素材、生成结构、修复输出，但家庭的判断和叙事权始终留在用户手里。</p>
        </article>
        <article className="card">
          <h3 data-i18n="v3Title">Private by design</h3>
          <p data-i18n="v3Desc">开源版从 macOS 桌面、本地文件、PostgreSQL + pgvector 和隔离 workspace 开始，把隐私和可迁移放在底层。</p>
        </article>
      </div>
    </section>
  );
};

export default VisionSection;