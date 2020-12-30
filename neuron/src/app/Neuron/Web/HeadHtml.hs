{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Neuron.Web.HeadHtml
  ( HeadHtml,
    getHeadHtml,
    renderHeadHtml,
  )
where

import Neuron.CLI.Types (MonadApp (getNotesDir, needFile))
import Reflex.Dom.Core
import Reflex.Dom.Pandoc (PandocBuilder)
import Reflex.Dom.Pandoc.PandocRaw (PandocRaw (..))
import Relude
import System.Directory (doesFileExist)
import System.FilePath ((</>))
import Text.Pandoc.Definition (Format (..))

newtype HeadHtml = HeadHtml (Maybe Text)

getHeadHtml :: (MonadIO m, MonadApp m) => m HeadHtml
getHeadHtml = do
  headHtmlPath <- getNotesDir <&> (</> "head.html")
  liftIO (doesFileExist headHtmlPath) >>= \case
    True -> do
      needFile headHtmlPath
      HeadHtml . Just <$> readFileText headHtmlPath
    False ->
      pure $ HeadHtml Nothing

renderHeadHtml :: PandocBuilder t m => HeadHtml -> m ()
renderHeadHtml (HeadHtml headHtml) = case headHtml of
  Nothing ->
    -- Include the MathJax script if no custom head.html is provided.
    elAttr "script" ("id" =: "MathJax-script" <> "src" =: "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js" <> "async" =: "") blank
  Just html ->
    elPandocRaw (Format "html") html
