/*
 *  TAO Translator
 *  Copyright (C) 2013-2018  Oleksii Serdiuk <contacts[at]oleksii[dot]name>
 *
 *  $Id: $Format:%h %ai %an$ $
 *
 *  This file is part of TAO Translator.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "yandextranslate.h"
#include "apikeys.h"

#include <QStringList>
#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
#   include <QUrlQuery>
#endif

QString YandexTranslate::displayName()
{
    return tr("Yandex.Translate");
}

YandexTranslate::YandexTranslate(QObject *parent) :
    YandexTranslationService(parent)
{
    // TODO: Download actual list from
    // https://translate.yandex.net/api/v1.5/tr.json/getLangs
    loadLanguages(QLatin1String("://langs/yandex.translate.json"));
}

QString YandexTranslate::uid() const
{
    return "YandexTranslate";
}

bool YandexTranslate::supportsTranslation() const
{
    return true;
}

bool YandexTranslate::supportsDictionary() const
{
    return false;
}

LanguagePair YandexTranslate::defaultLanguagePair() const
{
    return LanguagePair(Language("", getLanguageName("")), Language("en", getLanguageName("en")));
}

bool YandexTranslate::translate(const Language &from, const Language &to, const QString &text)
{
    QString lang;
    if (!from.info.toString().isEmpty())
        lang.append(from.info.toString()).append("-");
    lang.append(to.info.toString());

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query("https://translate.yandex.net/api/v1.5/tr.json/translate");
    QUrl dataQuery;
#else
    QUrl url("https://translate.yandex.net/api/v1.5/tr.json/translate");
    QUrlQuery dataQuery, query;
#endif
    query.addQueryItem("key", YANDEXTRANSLATE_API_KEY);
    query.addQueryItem("lang", lang);
    query.addQueryItem("options", "1");

    dataQuery.addQueryItem("text", text);

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QNetworkRequest request(query);
    const QByteArray data(dataQuery.encodedQuery());
#else
    url.setQuery(query);
    QNetworkRequest request(url);
    const QByteArray data(dataQuery.toString(QUrl::FullyEncoded).toUtf8());
#endif
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded;charset=UTF-8");
    request.setSslConfiguration(m_sslConfiguration);

    m_reply = m_nam.post(request, data);

    return true;
}

bool YandexTranslate::parseReply(const QByteArray &reply)
{
    const QVariant data = parseJson(reply);
    if (!data.isValid())
        return false;

    if (data.toMap().value("detected").type() == QVariant::Map) {
        const QString detected = data.toMap().value("detected").toMap().value("lang").toString();
        m_detectedLanguage = Language(detected, getLanguageName(detected));
    }

    m_translation = data.toMap().value("text").toStringList().join("");

    return true;
}
