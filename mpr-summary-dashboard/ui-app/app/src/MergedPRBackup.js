import React from 'react';
// Or import the input component
import DayPickerInput from 'react-day-picker/DayPickerInput';
import axios from 'axios';

import 'react-day-picker/lib/style.css';

import ReactTable from "react-table";
import "react-table/react-table.css";

var config = require('./config.json');

const hostUrl = config.url + config.service_path;




// const ssl = {
//     keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
//     keyStorePassword:"ballerina",
//     certPassword:"ballerina",
//     sslVerifyClient:"require",
//     trustStoreFile:"${ballerina.home}/bre/security/ballerinaTruststore.p12",
//     trustStorePassword:"ballerina",
//     ciphers:"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
//     sslEnabledProtocols:"TLSv1.2,TLSv1.1"
// };


const styles = {

    tableDropDown: {
        textAlign:'center',
        padding:'5px',
        boxShadow: 'inset 0px 0px 10px 1px #e5e5e5',
        borderRadius:'3px',
        border:'#FEFEFE 1px solid',
    },
    menuDropDown: {
        textAlign:'center',
        padding:'5px',
        boxShadow: 'inset 0px 0px 10px 1px #e5e5e5',
        borderRadius:'3px',
        border:'#FEFEFE 1px solid',
    },
    tableTitle: {
        textDecoration:'underline',
        color:'#3e86f9',
    },
    menuButton: {
        textAlign:'center',
        padding:'5px',
        boxShadow: 'inset 0px 0px 10px 1px #e5e5e5',
        borderRadius:'5px',
        border:'#FEFEFE 1px solid',
    },
    menuLabels: {
        color:'#3d3e44',
        font:'Arial',
    }
};

const States = ['Undefined','Draft Received','No Draft','In-progress','Issues Pending','Completed','No Impact'];
const Colors = ['#a6a7a8','#eddd8e','#ef4747','#deef47','#ef9247','#8fef47','#b9d7e8'];

function getMenuDropDownStyle(state) {
    var style = Object.assign({},styles.tableDropDown);
    style.backgroundColor = Colors[state];
    return style;
};

class MergedPR extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            error: null,
            isLoadedProduct: false,
            isLoadedVersion:false,
            isLoadedPrs:false,
            products: [],
            selectedProduct: '',
            productVersions:[],
            selectedVersion:'',
            pullRequests:[],
            selectedDayFrom:undefined,
            selectedDayTo:undefined,
            mapNumToStatus:null,
        };
        this.handleProductChange = this.handleProductChange.bind(this);
        this.handleVersionChange = this.handleVersionChange.bind(this);
        this.onDayFromChange = this.onDayFromChange.bind(this);
        this.onDayToChange = this.onDayToChange.bind(this);
        this.handleStatusChange = this.handleStatusChange.bind(this);
        this.handleDisplayPrs = this.handleDisplayPrs.bind(this);
        this.componentDidMount = this.componentDidMount.bind(this);
    }


    loadVersions(product) {
        axios.get(hostUrl+'/versions?product='+product)
            .then(response => {
                if(response.hasOwnProperty("data")) {
                    this.setState({
                        isLoadedVersion: true,
                        productVersions: response.data.data,
                        selectedVersion: response.data.data[0],
                    });
                }
            })
            .catch(error => {
                this.setState({
                    isLoadedVersion: true,
                    productVersions: [],
                    selectedVersion: '',
                    error: error,
                });
            });
    }


    handleProductChange(event) {
        this.setState({selectedProduct: event.target.value});
        this.loadVersions(event.target.value);
    }

    handleVersionChange(event) {
        this.setState({selectedVersion: event.target.value});
    }


    onDayFromChange(selectedDay, modifiers) {
        selectedDay.setHours(5,30,0);
        this.setState({selectedDayFrom:selectedDay });
    }

    onDayToChange(selectedDay, modifiers) {
        selectedDay.setHours(5,30,0);
        this.setState({selectedDayTo:selectedDay });
    }


    handleDisplayPrs() {
        if(this.state.selectedDayFrom===undefined || this.state.selectedDayTo===undefined ||
            this.state.selectedDayTo<this.state.selectedDayFrom) {
            alert("Please select a valid date range to display pull requests.");
            return;
        }  else if(this.state.selectedVersion===undefined) {
            alert("There are no version entries of this product at the moment.");
            return;
        }
        var product = this.state.selectedProduct.replace(" ","%20");
        var ver = this.state.selectedVersion.replace(" ","%20");
        var url = hostUrl + '/prs?';
        url += 'product='+product+'&';
        url += 'version='+ver+'&';
        url += 'start='+this.state.selectedDayFrom.toISOString();
        url += '&end='+this.state.selectedDayTo.toISOString();
        axios.get(url)
            .then(response => {
                if(response.hasOwnProperty("data")) {
                    var mapNumToStatus = new Map();
                    for(var i in response.data.data) {
                        var pr = response.data.data[i];
                        var record = {
                            prId:pr.prId,
                            docStatus:pr.docStatus,
                            marketingStatus:pr.marketingStatus,
                        };
                        mapNumToStatus.set(pr.prId,record);
                    }
                    this.setState({
                        isLoadedPrs:response.data.data.length>0,
                        pullRequests: response.data.data,
                        mapNumToStatus: mapNumToStatus,
                    });
                } else {
                    this.setState({
                        isLoadedPrs: false,
                        pullRequests: [],
                        mapNumToStatus:null,
                        error: "Could not load data from the backend.",
                    });
                }
            })
            .catch(error => {
                this.setState({
                    isLoadedPrs: false,
                    pullRequests: [],
                    mapNumToStatus:null,
                    error: error,
                });
            });

    }


    handleStatusChange(event) {
        for(let node of event.target) {
            if(node.value===event.target.value) {
                let mapNumToStatus = new Map(this.state.mapNumToStatus);
                var key = parseInt(node.getAttribute('data-id'),10);
                var value = States.indexOf(event.target.value);
                var record = mapNumToStatus.get(key);
                if(node.getAttribute('data-type')==='doc')
                    record.docStatus = value;
                else if(node.getAttribute('data-type')==='marketing')
                    record.marketingStatus = value;
                this.setState({
                    mapNumToStatus:mapNumToStatus,
                });

                axios.post(hostUrl + '/setdoc', {
                    records:[record],
                })
                    .then(response => {
                        console.log(response);
                    })
                    .catch(error => {
                        console.log(error);
                    });

                break;
            }
        }
    }

    componentDidMount() {
        axios.get(hostUrl+'/products')
            .then(response => {
                if(response.hasOwnProperty("data")) {
                    this.setState({
                        isLoadedProduct: true,
                        products: response.data.data,
                        selectedProduct: response.data.data[0],
                    });
                    this.loadVersions(response.data.data[0]);
                }
            })
            .catch(error => {
                this.setState({
                    isLoadedProduct: true,
                    error: error,
                });
            });


    }

    render() {
        if (this.state.error) {
            return <div>Error: {this.state.error.message}</div>;
        } else if (!this.state.isLoadedProduct || !this.state.isLoadedVersion) {
            return <div>Loading...</div>;
        } else {
            return (
                <div>
                    <b style={styles.menuLabels}>{'Product: '}</b>
                    <select style={styles.menuDropDown}
                            onChange={this.handleProductChange}>
                        {this.state.products.map(product => (
                            <option value={product} key={product}>
                                {product}
                            </option>
                        ))}
                    </select>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b style={styles.menuLabels}>{'Version: '}</b>
                    <select style={styles.menuDropDown}
                            onChange={this.handleVersionChange}>
                        {this.state.productVersions.map(version => (
                            <option value={version} key={version}>
                                {version}
                            </option>
                        ))}
                    </select>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b style={styles.menuLabels}>{'Date From: '}</b>
                    <DayPickerInput
                        value = {this.state.selectedDayFrom}
                        dayPickerProps={{
                            showWeekNumbers:true,
                            selectedDays:this.state.selectedDayFrom,
                        }}
                        onDayChange={this.onDayFromChange}
                    />
                    &nbsp;&nbsp;
                    <b style={styles.menuLabels}>{'To: '}</b>
                    <DayPickerInput
                        value = {this.state.selectedDayTo}
                        dayPickerProps={{
                            showWeekNumbers:true,
                            selectedDays:this.state.selectedDayTo,
                        }}
                        onDayChange={this.onDayToChange}
                    />
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <button style={styles.menuButton}
                            type="button"
                            onClick={this.handleDisplayPrs}
                            disabled={this.state.selectedDayFrom===undefined}>
                        {'Display PRs'}
                    </button>
                    <hr/>
                    {this.state.isLoadedPrs &&
                    <div>
                        <ReactTable
                            data={this.state.pullRequests}
                            filterable
                            columns={[
                                {
                                    Header: "PR Subject",
                                    id: 'prTitle',
                                    minWidth:300,
                                    accessor:d => (
                                        <a style={styles.tableTitle} href={d.prUrl} target={'_blank'}>
                                            {d.prTitle}
                                        </a>
                                    ),
                                    filterMethod: (filter,row) => {
                                        var a = row[filter.id].props.children.toLowerCase();
                                        return a.includes(filter.value.toLowerCase());
                                    }
                                },
                                {
                                    Header: "Merged Date",
                                    id: 'mergedDate',
                                    width:200,
                                    accessor:d => (new Date(d.mergedDate.time)).toDateString(),
                                    filterable:false,
                                    sortMethod: (a, b) => {
                                        var dayA = new Date(a);
                                        var dayB = new Date(b);
                                        return dayA > dayB;
                                    }
                                },
                                {
                                    Header: "Doc Status",
                                    id: 'docStatus',
                                    sortable:false,
                                    width:200,
                                    filterMethod: (filter,row) => {
                                        var a = row[filter.id].props.value.toLowerCase();
                                        return a.includes(filter.value.toLowerCase());
                                    },
                                    accessor:d => (
                                        <select style={getMenuDropDownStyle(this.state.mapNumToStatus.get(d.prId).docStatus)}
                                                onChange={this.handleStatusChange }
                                                key={"doc-"+d.prId}
                                                value ={States[this.state.mapNumToStatus.get(d.prId).docStatus]}>
                                            {
                                                States.map(state => (
                                                    <option key={"doc-" + state+"-"+d.prId}
                                                            value={state}
                                                            data-id={d.prId}
                                                            data-type="doc">
                                                        {state}
                                                    </option>
                                                ))
                                            }
                                        </select>

                                    ),
                                },
                                {
                                    Header: "Marketing Status",
                                    id: 'marketingStatus',
                                    sortable:false,
                                    width:200,
                                    filterMethod: (filter,row) => {
                                        var a = row[filter.id].props.value.toLowerCase();
                                        return a.includes(filter.value.toLowerCase());
                                    },
                                    accessor:d => (
                                        <select style={getMenuDropDownStyle(this.state.mapNumToStatus.get(d.prId).marketingStatus)}
                                                onChange={this.handleStatusChange}
                                                key={"marketing-"+d.prId}
                                                value ={States[this.state.mapNumToStatus.get(d.prId).marketingStatus]}>
                                            {
                                                States.map(state => (
                                                    <option key={"marketing-" + state+"-"+d.prId}
                                                            value={state}
                                                            data-id={d.prId}
                                                            data-type="marketing">
                                                        {state}
                                                    </option>
                                                ))
                                            }
                                        </select>

                                    ),
                                }
                            ]}
                            defaultPageSize={10}
                            className="-striped -highlight"
                        />
                    </div>
                    }
                </div>


            );
        }
    }
}

export default MergedPR;