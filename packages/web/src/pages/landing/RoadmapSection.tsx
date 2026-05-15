import React from 'react';

const RoadmapSection: React.FC = () => {
  return (
    <section id="roadmap">
      <div className="head">
        <h2 data-i18n="roadTitle">一套完整的家庭记忆出版系统。</h2>
        <p data-i18n="roadDesc">KidMemory 把桌面工作台、私人素材库、语义搜索、Agent 生成、稳定导出和 Web Companion 采集合在同一条产品体验里，让家庭记忆从收集到出版自然流动。</p>
      </div>
      <div className="road">
        <article className="phase">
          <b data-i18n="r1Label">Studio</b>
          <h3 data-i18n="r1Title">桌面工作台</h3>
          <p data-i18n="r1Desc">macOS 桌面端承载孩子档案、素材整理、作品预览、生成任务和导出中心。</p>
        </article>
        <article className="phase">
          <b data-i18n="r2Label">Library</b>
          <h3 data-i18n="r2Title">私人素材库</h3>
          <p data-i18n="r2Desc">真实图片导入、metadata 编辑、标签管理、自然语言搜图、匹配原因和候选素材池。</p>
        </article>
        <article className="phase">
          <b data-i18n="r3Label">Agent</b>
          <h3 data-i18n="r3Title">可控生成系统</h3>
          <p data-i18n="r3Desc">Agent 在隔离 workspace 中生成结构化书稿，系统负责日志、校验、修复和稳定导出。</p>
        </article>
        <article className="phase">
          <b data-i18n="r4Label">Upload</b>
          <h3 data-i18n="r4Title">Web Companion 上传</h3>
          <p data-i18n="r4Desc">手机网页扫码进入 3 小时上传会话，单次最多 200 张，局域网优先，Supabase Storage 公网直传兜底。</p>
        </article>
        <article className="phase">
          <b data-i18n="r5Label">Share</b>
          <h3 data-i18n="r5Title">浏览与分享</h3>
          <p data-i18n="r5Desc">Web Companion 承接最近上传、轻量浏览、作品集查看、PDF / 长图分享和亲友传阅。</p>
        </article>
      </div>
    </section>
  );
};

export default RoadmapSection;
