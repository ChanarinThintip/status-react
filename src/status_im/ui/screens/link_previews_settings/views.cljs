(ns status-im.ui.screens.link-previews-settings.views
  (:require-macros [status-im.utils.views :as views])
  (:require [re-frame.core :as re-frame]
            [status-im.i18n :as i18n]
            [status-im.ui.components.react :as react]
            [status-im.ui.components.list.views :as list]
            [status-im.ui.components.colors :as colors]
            [quo.core :as quo]
            [status-im.ui.components.icons.vector-icons :as icons]
            [status-im.react-native.resources :as resources]
            [status-im.ui.components.topbar :as topbar])
  )

(defn prepare-urls-items-data [link-previews-enabled]
  (fn [[site {:keys [url title]}]]
    (let [enabled? (contains? link-previews-enabled site)]
     {:title     title
     :subtitle  url
     :size      :small
     :accessory :switch
     :active    (contains? link-previews-enabled site);enabled?
     :on-press #(re-frame/dispatch
                 [:multiaccounts.ui/set-link-preview site ((complement boolean) enabled?)])
     }
      )
    ))


(views/defview link-previews-settings []
  (views/letsubs [{:keys [link-previews-whitelist link-previews-enabled]} [:multiaccount]]
    [react/view {:flex 1}
     [topbar/topbar {:title (i18n/label :t/chat-link-previews)}]
     [react/image {:source      (resources/get-theme-image :unfurl)
                   :resize-mode :contain
                   :style       {:width 200 :height 200}}]
     [react/text (i18n/label :t/you-can-choose-preview-websites)]
     
     [quo/separator {:style {:margin-vertical  8}}]
     
     
     [quo/list-header (i18n/label :t/websites)]
     [quo/button {:on-press #(doseq [site (keys link-previews-whitelist)]
                              (re-frame/dispatch 
                               [:multiaccounts.ui/set-link-preview site true]))
                  :type     :secondary}
      (i18n/label :t/enable-all)]
     
     [list/flat-list
      {:data      (vec (map (prepare-urls-items-data link-previews-enabled) link-previews-whitelist))
       :key-fn    (fn [_ i] (str i))
       :render-fn quo/list-item
       :footer [react/i18n-text {:key :t/previewing-may-share-metadata
                                 :styles {:color colors/gray}}]}
      ]
     ]))
