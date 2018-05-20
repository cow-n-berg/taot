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

#include "yandexdictionaries.h"
#ifdef Q_OS_BLACKBERRY
#   include "bb10/dictionarymodel.h"
#   include "bb10/reversetranslationsmodel.h"
#else
#   include "dictionarymodel.h"
#endif
#include "apikeys.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
#   include <QUrlQuery>
#endif

QString YandexDictionaries::displayName()
{
    return tr("Yandex.Dictionaries");
}

YandexDictionaries::YandexDictionaries(DictionaryModel *dict, QObject *parent)
    : YandexTranslationService(parent)
    , m_dict(dict)
{
    // TODO: Download actual list from
    // https://dictionary.yandex.net/api/v1/dicservice.json/getLangs
    loadLanguages(QLatin1String("://langs/yandex.dictionaries.json"), false);
}

QString YandexDictionaries::uid() const
{
    return "YandexDictionaries";
}

bool YandexDictionaries::supportsTranslation() const
{
    return false;
}

bool YandexDictionaries::supportsDictionary() const
{
    return true;
}

LanguagePair YandexDictionaries::defaultLanguagePair() const
{
    return LanguagePair(Language("en", getLanguageName("en")),
                        Language("en", getLanguageName("en")));
}

bool YandexDictionaries::translate(const Language &from, const Language &to, const QString &text)
{
    QString lang;
    lang.reserve(5);
    lang.append(from.info.toString()).append("-").append(to.info.toString());

#if QT_VERSION < QT_VERSION_CHECK(5,0,0)
    QUrl query("https://dictionary.yandex.net/api/v1/dicservice.json/lookup");
    QUrl dataQuery;
#else
    QUrl url("https://dictionary.yandex.net/api/v1/dicservice.json/lookup");
    QUrlQuery query, dataQuery;
#endif
    query.addQueryItem("ui", "en");
    query.addQueryItem("key", YANDEXDICTIONARIES_API_KEY);
    query.addQueryItem("lang", lang);

    dataQuery.addQueryItem("text", text.trimmed());

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

bool YandexDictionaries::parseReply(const QByteArray &reply)
{
    const QVariant data = parseJson(reply);
    if (!data.isValid())
        return false;

    QHash<QString, DictionaryPos> poses;
    QSet<QString> transcriptions;
    foreach (const QVariant &di, data.toMap().value("def").toList()) {
        const QString trans = di.toMap().value("ts").toString();
        if (!trans.isEmpty())
            transcriptions.insert(trans);
        foreach (const QVariant &pi, di.toMap().value("tr").toList()) {
            const QString posname = pi.toMap().value("pos").toString();
            DictionaryPos pos = poses.value(posname, DictionaryPos(posname));
            pos.translations().append(pi.toMap().value("text").toString());

            QStringList mean;
            foreach (const QVariant &mi, pi.toMap().value("mean").toList()) {
                mean << mi.toMap().value("text").toString();
            }
            if (mean.isEmpty())
                mean << QLatin1String("---");

            QStringList syn;
            foreach (const QVariant &si, pi.toMap().value("syn").toList()) {
                syn << si.toMap().value("text").toString();
            }

            pos.reverseTranslations()->append(pi.toMap().value("text").toString(),
                                              syn,
                                              mean);
            poses.insert(posname, pos);
        }
    }

    if (poses.isEmpty()) {
        m_error = commonString(EmptyResultCommonString).arg(displayName());
        return true;
    }

    m_transcription = StringPair();
    if (!transcriptions.isEmpty()) {
        //: Separator for joining string lists (don't forget space after comma)
        m_transcription.first
                = "[" + QStringList(transcriptions.toList()).join("]" + tr(", ") + "[") + "]";
    }

    m_dict->clear();
    foreach (DictionaryPos pos, poses) {
        m_dict->append(pos);
    }

    return true;
}
