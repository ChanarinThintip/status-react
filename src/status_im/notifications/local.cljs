(ns status-im.notifications.local
  (:require [taoensso.timbre :as log]
            [clojure.string :as cstr]
            [status-im.utils.fx :as fx]
            [status-im.ethereum.decode :as decode]
            ["@react-native-community/push-notification-ios" :default pn-ios]
            [status-im.notifications.android :as pn-android]
            [status-im.ethereum.tokens :as tokens]
            [status-im.utils.utils :as utils]
            [status-im.utils.types :as types]
            [status-im.utils.money :as money]
            [status-im.i18n :as i18n]
            [quo.platform :as platform]
            [re-frame.core :as re-frame]
            [status-im.ui.components.react :as react]))

(def default-erc20-token
  {:symbol   :ERC20
   :decimals 18
   :name     "ERC20"})

(defn local-push-ios [{:keys [title message]}]
  (.presentLocalNotification pn-ios #js {:alertBody  message
                                         :alertTitle title}))

(defn local-push-android [{:keys [title message icon]}]
  (pn-android/present-local-notification (merge {:channelId "status-im-notifications"
                                                 :title     title
                                                 :message   message}
                                                (when icon
                                                  {:largeIconUrl (:uri (react/resolve-asset-source icon))}))))

(defn create-notification [{{:keys [state from to value erc20 chain contract]
                             :or   {chain "ropsten"}} :body}]
  (let [token        (if erc20
                       (get-in tokens/all-tokens-normalized [(keyword chain)
                                                             (cstr/lower-case contract)]
                               default-erc20-token)
                       (tokens/native-currency (keyword chain)))
        amount       (money/wei->ether (decode/uint value))
        account-to   @(re-frame/subscribe [:account-by-address to])
        account-from @(re-frame/subscribe [:account-by-address from])
        to           (or (:name account-to) (utils/get-shortened-address to))
        from         (or (:name account-from) (utils/get-shortened-address from))
        title        (case state
                       "inbound"  (i18n/label :t/push-inbound-transaction {:value    amount
                                                                           :currency (:symbol token)})
                       "outbound" (i18n/label :t/push-outbound-transaction {:value    amount
                                                                            :currency (:symbol token)})
                       "failed"   (i18n/label :t/push-failed-transaction {:value    amount
                                                                          :currency (:symbol token)})
                       nil)
        description  (case state
                       "inbound"  (i18n/label :t/push-inbound-transaction-body {:from from
                                                                                :to   to})
                       "outbound" (i18n/label :t/push-outbound-transaction-body {:from from
                                                                                 :to   to})
                       "failed"   (i18n/label :t/push-failed-transaction-body {:value    amount
                                                                               :currency (:symbol token)
                                                                               :to       to})
                       nil)]
    {:title   title
     :icon    (get-in token [:icon :source])
     :message description}))

(re-frame/reg-fx
 ::local-push-ios
 (fn [evt]
   (-> evt create-notification local-push-ios)))

(fx/defn process
  [_ evt]
  (when platform/ios?
    {::local-push-ios evt}))

(defn handle []
  (fn [^js message]
    (let [evt (types/json->clj (.-event message))]
      (js/Promise.
       (fn [on-success on-error]
         (try
           (when (= "local-notifications" (:type evt))
             (-> (:event evt) create-notification local-push-android))
           (on-success)
           (catch :default e
             (log/warn "failed to handle background notification" e)
             (on-error e))))))))
